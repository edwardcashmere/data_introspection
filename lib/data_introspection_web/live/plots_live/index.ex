defmodule DataIntrospectionWeb.PlotsLive.Index do
  @moduledoc false
  use DataIntrospectionWeb, :live_view

  import DataIntrospectionWeb.PlotsLive.Helper

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:render_plots, plots}, socket) do
    datasets = build_datatsets(plots)

    {:noreply, push_event(socket, "render-plots", %{datasets: datasets})}
  end

  defp apply_action(socket, :self, _params) do
    plots = DataIntrospection.Plots.list_user_plots(socket.assigns.current_user)
    send(self(), {:render_plots, plots})
    assign(socket, page_title: "Private Plots", plots: plots)
  end

  defp apply_action(socket, :shared, _params) do
    plots = DataIntrospection.Plots.list_user_plots(socket.assigns.current_user)
    send(self(), {:render_plots, plots})
    assign(socket, page_title: "Shared Plots", plots: plots)
  end

  defp apply_action(socket, _live_action, _params), do: socket

  defp build_datatsets(plots) do
    Enum.reduce(plots, [], fn plot, acc ->
      {headers, _first_row, data} = [get_file_path(), plot.dataset] |> Path.join() |> parse_csv()

      [%{id: plot.id, dataset: format_dataset(data, headers, plot.expression)} | acc]
    end)
  end
end
