defmodule DataIntrospection.PlotsTest do
  @moduledoc false
  use DataIntrospection.DataCase

  alias DataIntrospection.Plots
  alias DataIntrospection.Plots.Plot

  describe "create_plot/1" do
    test "should create a new plot with valid attrs" do
      attrs = params_for(:plot)
      assert {:ok, %Plot{}} = Plots.create_plot(attrs)
    end

    test "should not create a new plot with invalid attrs" do
      attrs = %{}
      assert {:error, %Ecto.Changeset{} = changeset} = Plots.create_plot(attrs)

      assert %{
               title: ["can't be blank"],
               dataset: ["can't be blank"],
               expression: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "update_plot/2" do
    test "should update a plot with valid attrs" do
      plot = insert(:plot)
      attrs = %{title: "New Title", dataset: "New Dataset", expression: "New Expression"}
      assert {:ok, %Plot{}} = Plots.update_plot(plot, attrs)
    end

    test "should not update a plot with invalid attrs" do
      plot = insert(:plot)
      attrs = %{title: "", dataset: "", expression: ""}
      assert {:error, %Ecto.Changeset{} = changeset} = Plots.update_plot(plot, attrs)

      assert %{
               title: ["can't be blank"],
               dataset: ["can't be blank"],
               expression: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "list_user_plots/1" do
    test "should list all plots for a user" do
      user = insert(:user)
      plots = insert_list(5, :plot)

      plots
      |> Enum.take(3)
      |> Enum.each(fn plot ->
        insert(:policy, subject: user, resource: plot, action: "edit")
      end)

      assert [%Plot{} | _] = plots = Plots.list_user_plots(user, "edit")
      assert length(plots) == 3
    end

    test "should return an empty list if user has no plots" do
      user = insert(:user)
      assert [] = Plots.list_user_plots(user, "view")
    end
  end

  describe "delete_plot/1" do
    test "should delete a plot" do
      plot = insert(:plot)
      assert {:ok, %Plot{}} = Plots.delete(plot)
    end
  end

  describe "change_plot/2" do
    test "should return a changeset for a plot" do
      assert %Ecto.Changeset{} = Plots.change_plot(%Plot{}, %{title: "New Title"})
    end
  end

  describe "get_plot!/1" do
    test "should return a plot by id" do
      plot = insert(:plot)
      assert %Plot{} = Plots.get_plot!(plot.id)
    end

    test "should raise if the plot does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Plots.get_plot!(Ecto.UUID.generate())
      end
    end
  end
end
