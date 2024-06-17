defmodule DataIntrospectionWeb.PlotsLive.IndexTest do
  @moduledoc false
  use DataIntrospectionWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "On initial render" do
    test "should render private page_title when on your plots tab", %{conn: conn, user: user} do
      {:ok, lv, html} = live(conn, ~p"/plots/private/#{user}")
      assert html =~ "Private Plots"
      assert has_element?(lv, "[data-role='create-new-plot']")
    end

    test "should render shared page_title when on shared plots tab", %{conn: conn, user: user} do
      {:ok, lv, html} = live(conn, ~p"/plots/shared/#{user}")
      assert html =~ "Shared Plots"
      refute has_element?(lv, "[data-role='create-new-plot']")
    end

    test "should render all the plots the user owns on the your plots tab", %{
      conn: conn,
      user: user
    } do
      plot_1 = insert(:plot, dataset: "data.csv", expression: "x")
      plot_2 = insert(:plot, dataset: "data.csv", expression: "y")

      insert(:policy, subject: user, resource: plot_1, action: "*")
      insert(:policy, subject: user, resource: plot_2, action: "*")

      {:ok, lv, _html} = live(conn, ~p"/plots/private/#{user}")

      assert has_element?(lv, "[data-role='plot.#{plot_1.id}']")
      assert has_element?(lv, "[data-role='plot.#{plot_2.id}']")
    end

    test "should render all the plots the user has access to on the shared plots tab", %{
      conn: conn,
      user: user
    } do
      plot_1 = insert(:plot, dataset: "data.csv", expression: "x")
      plot_2 = insert(:plot, dataset: "data.csv", expression: "y")

      insert(:policy, subject: user, resource: plot_1, action: "view")
      insert(:policy, subject: user, resource: plot_2, action: "view")

      {:ok, lv, _html} = live(conn, ~p"/plots/shared/#{user}")

      assert has_element?(lv, "[data-role='plot.#{plot_1.id}']")
      assert has_element?(lv, "[data-role='plot.#{plot_2.id}']")
    end
  end

  describe "edit plots" do
    test "should render a form to edit a plot", %{conn: conn, user: user} do
      plot = insert(:plot)
      insert(:policy, subject: user, resource: plot, action: "*")

      {:ok, lv, _html} = live(conn, ~p"/plots/edit/#{plot.id}")

      assert has_element?(lv, "#edit-plot-form")
    end
  end

  describe "when clicking the new plot button" do
    test "should redirect to the new plot page", %{conn: conn, user: user} do
      {:ok, lv, html} = live(conn, ~p"/plots/private/#{user}")
      assert html =~ "Private Plots"

      assert {:ok, _lv, _html} =
               lv
               |> element("[data-role='create-new-plot']")
               |> render_click()
               |> follow_redirect(conn, ~p"/plots/new")
    end
  end
end
