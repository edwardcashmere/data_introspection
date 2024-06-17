defmodule DataIntrospectionWeb.Hook.CheckPermission do
  @moduledoc false

  use Phoenix.Component
  import Phoenix.LiveView
  import DataIntrospectionWeb.UserAuth, only: [signed_in_path: 1]

  alias DataIntrospection.AccessControl
  alias DataIntrospection.Plots

  #  def on_mount(
  #       :check_organization_ownership,
  #       %{"organization_id" => "mine"} = params,
  #       session,
  #       socket
  #     ) do
  #   %{assigns: %{current_user: current_user}} = socket = mount_current_user(session, socket)

  #   if is_nil(current_user.organization_id) do
  #     {:halt,
  #      socket
  #      |> put_flash(
  #        :error,
  #        "You do not belong to an organization. Please contact your administrator if you believe this is an error."
  #      )
  #      |> redirect(to: signed_in_path(socket))}
  #   else
  #     on_mount(
  #       :check_organization_ownership,
  #       Map.put(params, "organization_id", current_user.organization_id),
  #       session,
  #       socket
  #     )
  #   end
  # end

  def on_mount(
        :check_owner,
        %{"id" => plot_id} = _params,
        _session,
        socket
      ) do
    %{assigns: %{current_user: current_user}} = socket = socket
    plot = Plots.get_plot!(plot_id)

    if AccessControl.check?(current_user, plot, "*") do
      {:cont, socket}
    else
      {:halt,
       socket
       |> put_flash(:error, "Unauthorized")
       |> redirect(to: signed_in_path(socket))}
    end
  end

  def on_mount(
        :check_shared,
        %{"id" => plot_id} = _params,
        _session,
        socket
      ) do
    %{assigns: %{current_user: current_user}} = socket = socket
    plot = Plots.get_plot!(plot_id)

    case AccessControl.check?(current_user, plot, "view") do
      true ->
        {:cont, socket}

        {:halt,
         socket
         |> put_flash(:error, "Unauthorized")
         |> redirect(to: signed_in_path(socket))}
    end
  end
end
