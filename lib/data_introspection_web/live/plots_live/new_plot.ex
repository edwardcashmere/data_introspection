defmodule DataIntrospectionWeb.PlotsLive.NewPlot do
  @moduledoc false
  use DataIntrospectionWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, dataset: [], plot_name: "", dataset_name: "")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, params) do
    # create a new plot changeset
    # insert it and use it
    socket
  end

  defp apply_action(socket, :edit, params) do
    # find the plot by id
    # create a form and allow edit
    socket
  end

  defp apply_action(socket, _, _params), do: socket
end
