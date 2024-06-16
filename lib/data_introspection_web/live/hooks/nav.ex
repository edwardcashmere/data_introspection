defmodule DataIntrospectionWeb.Hook.Nav do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.LiveView

  @doc """
    set up tab assigns
  """
  @spec on_mount(:default, map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(:default, _params, _session, socket) do
    {:cont, attach_hook(socket, :tab, :handle_params, &handle_active_page/3)}
  end

  defp handle_active_page(_params, _url, socket) do
    tab = do_handle_active_page(socket.assigns.live_action, socket.view)

    {:cont, assign(socket, :tab, tab)}
  end

  defp do_handle_active_page(:self, DataIntrospectionWeb.PlotsLive.Index), do: :self
  defp do_handle_active_page(:shared, DataIntrospectionWeb.PlotsLive.Index), do: :shared
  defp do_handle_active_page(_, _), do: nil
end
