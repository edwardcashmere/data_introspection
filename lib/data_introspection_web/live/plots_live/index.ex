defmodule DataIntrospectionWeb.PlotsLive.Index do
  @moduledoc false
  use DataIntrospectionWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
