defmodule DataIntrospectionWeb.PlotsLive.FormComponent do
  @moduledoc false
  use DataIntrospectionWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end
end
