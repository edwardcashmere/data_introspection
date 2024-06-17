defmodule DataIntrospectionWeb.Nav do
  @moduledoc false
  use DataIntrospectionWeb, :html

  alias DataIntrospection.Accounts.User

  attr(:current_user, User, required: true)
  attr(:tab, :atom, required: true)
  @spec side_nav(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def side_nav(assigns) do
    ~H"""
    <aside class="flex z-20 flex-col h-screen bg-slate-300 w-64 shadow shadow-lg rounded-sm">
      <img
        src="https://assets-global.website-files.com/63ea11d4e90f21674a93fc5f/63ea378760030855f7bacafa_Logo-p-800.png"
        alt="logo"
        class="h-16 w-36 my-6 mx-2 object-contain"
      />
      <.nav_item
        name="Your plots"
        icon="hero-squares-plus-solid"
        href={~p"/plots/private/#{@current_user}"}
        tab={@tab}
        data_role="private-plots-link"
        tab_name={:self}
      />
      <.nav_item
        name="Shared with you"
        icon="hero-chart-bar-square-solid"
        href={~p"/plots/shared/#{@current_user}"}
        tab={@tab}
        data_role="shared-plots-link"
        tab_name={:shared}
      />
    </aside>
    """
  end

  attr(:name, :string, required: true)
  attr(:tab, :atom, required: true)
  attr(:icon, :string, required: true)
  attr(:href, :string, required: true)
  attr(:tab_name, :atom, required: true)
  attr(:data_role, :string, required: true)
  @spec nav_item(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def nav_item(assigns) do
    assigns =
      assign_new(assigns, :base_class, fn ->
        if assigns.tab == assigns.tab_name, do: "bg-slate-500", else: ""
      end)

    ~H"""
    <.link
      class={"flex space-x-2 items-center w-3/4 rounded-md my-4 mx-2 py-2 px-2 hover:bg-slate-500 #{@base_class}"}
      href={@href}
      data-role={@data_role}
    >
      <.icon name={@icon} class="h-6  w-6" />
      <span class="ml-2"><%= @name %></span>
    </.link>
    """
  end
end
