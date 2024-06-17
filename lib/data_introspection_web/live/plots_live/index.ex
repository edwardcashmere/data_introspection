defmodule DataIntrospectionWeb.PlotsLive.Index do
  @moduledoc false
  use DataIntrospectionWeb, :live_view

  import DataIntrospectionWeb.PlotsLive.Helper
  import LiveSelect

  alias DataIntrospection.AccessControl
  alias DataIntrospection.Accounts
  alias DataIntrospection.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "", plots: [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    search_term = String.downcase(text)

    options =
      Enum.filter(socket.assigns.options, fn {email, id} ->
        email |> String.downcase() |> String.contains?(search_term)
      end)

    send_update(LiveSelect.Component, id: live_select_id, options: options)

    {:noreply, socket}
  end

  def handle_event("share", %{"user" => %{"id" => user_id}}, socket) do
    %{assigns: %{plot: plot}} = socket

    socket =
      case AccessControl.create_policy("user.#{user_id}", plot, "view") do
        {:ok, _policy} ->
          socket
          |> put_flash(:info, "Plot shared successfully.")
          |> push_patch(to: ~p"/plots/private/#{plot}")

        {:error, _changeset} ->
          put_flash(socket, :error, "Failed to share plot. try again")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:render_plots, plots}, socket) do
    datasets = build_datasets(plots)

    {:noreply, push_event(socket, "render-plots", %{datasets: datasets})}
  end

  def handle_info({:update_plot, {plot_id, data}}, socket) do
    %{assigns: %{plots: plots}} = socket

    datasets =
      plots
      |> build_datasets()
      |> Enum.reduce([], fn plot, acc ->
        if plot.id == plot_id do
          [%{id: plot_id, dataset: data} | acc]
        else
          [plot | acc]
        end
      end)

    {:noreply, push_event(socket, "render-plots", %{datasets: datasets})}
  end

  defp apply_action(socket, :self, _params) do
    plots = DataIntrospection.Plots.list_user_plots(socket.assigns.current_user, "*")
    send(self(), {:render_plots, plots})
    assign(socket, page_title: "Private Plots", plots: plots)
  end

  defp apply_action(socket, :shared, _params) do
    plots = DataIntrospection.Plots.list_user_plots(socket.assigns.current_user, "view")

    # subscribe to plot changes
    :ok =
      Enum.each(plots, fn plot ->
        :ok = Phoenix.PubSub.subscribe(DataIntrospection.PubSub, "plot:#{plot.id}")
      end)

    :ok = Phoenix.PubSub.subscribe(DataIntrospection.PubSub, "plot:#{}")
    send(self(), {:render_plots, plots})
    assign(socket, page_title: "Shared Plots", plots: plots)
  end

  defp apply_action(socket, :share, params) do
    plot = DataIntrospection.Plots.get_plot!(params["id"])

    form =
      DataIntrospection.Accounts.change_user_registration(%User{}, %{}) |> to_form(as: "user")

    options =
      DataIntrospection.Accounts.list_users(socket.assigns.current_user)
      |> Enum.map(&{&1.email, &1.id})

    socket
    |> assign(page_title: "Share Plot #{plot.title}")
    |> assign(plot: plot)
    |> assign(options: options)
    |> assign(form: form)
  end

  defp apply_action(socket, _live_action, _params), do: socket

  defp build_datasets(plots) do
    Enum.reduce(plots, [], fn plot, acc ->
      {headers, _first_row, data} = [get_file_path(), plot.dataset] |> Path.join() |> parse_csv()

      updated_plot =
        if String.contains?(plot.expression, ["*", "/", "+", "-"]) do
          %{id: plot.id, dataset: format_dataset(data, headers, plot.expression)}
        else
          %{id: plot.id, dataset: filter_expression_data(headers, plot.expression, data)}
        end

      [updated_plot | acc]
    end)
  end

  defp get_collaborators(plot, user) do
    plot |> Accounts.get_all_plot_collaborators(user) |> Enum.map(& &1.email)
  end
end
