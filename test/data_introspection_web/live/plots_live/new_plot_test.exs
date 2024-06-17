defmodule DataIntrospectionWeb.PlotsLive.NewPlotTest do
  @moduledoc false
  use DataIntrospectionWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias DataIntrospection.Plots
  alias DataIntrospection.Plots.Plot

  setup :register_and_log_in_user

  describe "when rendering a new plot" do
    test "shoould  render a form to create a new plot", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/plots/new")

      assert html =~ "New Plot"
      assert has_element?(lv, "#new-plot-form")
    end

    # test "with valid data the form should create a new plot", %{conn: conn, user: user} do
    # credo:disable-for-lines:2
    # TODO live_select uses a hidden value to do submissions figure out a way around it
    # {:ok, lv, _html} = live(conn, ~p"/plots/new")

    # %{title: title} =
    #   plot_params = params_for(:plot)

    # {:ok, _updated_lv, updated_html} =
    #   lv
    #   |> form("#new-plot-form", plot: plot_params)
    #   |> render_submit()
    #   |> follow_redirect(conn, ~p"/plots/private/#{user}")

    # assert updated_html =~ "Plot created successfully."
    # assert [%Plot{title: ^title}] = Plots.list_user_plots(user, "edit")
    # end

    test "with invalid data the form should not create a new plot and show errors", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/plots/new")

      plot_params = %{}

      lv
      |> form("#new-plot-form", plot: plot_params)
      |> render_submit()

      assert lv |> render() |> html_contains_string?("can't be blank")

      assert render(lv) =~ "Error creating plot."
      assert [] = Plots.list_user_plots(user, "view")
    end
  end

  describe "when editing a plot" do
    test "with valid data the form should update the plot", %{conn: conn, user: user} do
      plot = insert(:plot)
      insert(:policy, subject: user, resource: plot, action: "*")

      {:ok, lv, _html} = live(conn, ~p"/plots/edit/#{plot.id}")

      updated_title = "Arsenal"

      {:ok, _updated_lv, updated_html} =
        lv
        |> form("#edit-plot-form", plot: %{title: updated_title})
        |> render_submit()
        |> follow_redirect(conn, ~p"/plots/private/#{user}")

      assert updated_html =~ "Plot updated successfully."
      assert [%Plot{title: ^updated_title}] = Plots.list_user_plots(user, "*")
    end

    test "with invalid data the form should not update the plot and show errors", %{
      conn: conn,
      user: user
    } do
      plot = insert(:plot)
      insert(:policy, subject: user, resource: plot, action: "*")

      {:ok, lv, _html} = live(conn, ~p"/plots/edit/#{plot.id}")

      lv
      |> form("#edit-plot-form", plot: %{title: ""})
      |> render_submit()

      assert lv |> render() |> html_contains_string?("can't be blank")

      assert render(lv) =~ "Error updating plot."
    end
  end

  # describe "should create a data set " do

  # end
end
