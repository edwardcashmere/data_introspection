defmodule DataIntrospectionWeb.DashboardLive.IndexTest do
  @moduledoc false
  use DataIntrospectionWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "when rendering the dashboard" do
    test "should render a yours plots tab link", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/")
      assert html =~ "Your plots"
      assert has_element?(lv, "[data-role='private-plots-link']")
    end

    test "should render a shared with you tab link", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/")
      assert html =~ "Shared with you"
      assert has_element?(lv, "[data-role='shared-plots-link']")
    end

    test "should redirect to the yours plots tab after clicking the yours plots tab link", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/")

      assert {:ok, _conn} =
               lv
               |> element("[data-role='private-plots-link']")
               |> render_click()
               |> follow_redirect(conn, "/plots/private/#{user.id}")
    end

    test "should redirect to the shared with you tab after clicking the shared with you tab link",
         %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/")

      assert {:ok, _conn} =
               lv
               |> element("[data-role='shared-plots-link']")
               |> render_click()
               |> follow_redirect(conn, "/plots/shared/#{user.id}")
    end
  end
end
