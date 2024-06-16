defmodule DataIntrospectionWeb.PlotsLive.NewPlotTest do
  @moduledoc false
  use DataIntrospectionWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "when rendering a new plot" do
    test "shoould  render a form to create a new plot", %{conn: conn, user: user} do
      {:ok, lv, html} = live(conn, ~p"/plots/new")

      assert html =~ "New Plot"
      assert has_element?(lv, "[data-role='new-plot-form']")
    end

    test "with valid data the form should create a new plot"
    test "with invalid data the form should not create a new plot and show errors"
  end

  describe "when editing a plot" do
    test "should render a form to edit a plot"
    test "with valid data the form should update the plot"
    test "with invalid data the form should not update the plot and show errors"
  end

  # describe "should create a data set " do

  # end
end
