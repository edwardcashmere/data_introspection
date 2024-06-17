defmodule DataIntrospection.Plots do
  @moduledoc """
  The Plots context.
  """

  import Ecto.Query, warn: false

  alias DataIntrospection.AccessControl
  alias DataIntrospection.Plots.Plot
  alias DataIntrospection.Repo

  @doc """
  create  plots with the given `attrs`.
  """
  @spec create_plot(map()) :: {:ok, Plot.t()} | {:error, Ecto.Changeset.t()}
  def create_plot(attrs) do
    %Plot{}
    |> Plot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
    update plots with the given `attrs`.
  """
  @spec update_plot(Plot.t(), map()) :: {:ok, Plot.t()} | {:error, Ecto.Changeset.t()}
  def update_plot(plot, attrs) do
    plot
    |> Plot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
    returns changeset for plots
  """
  @spec change_plot(Plot.t(), map()) :: Ecto.Changeset.t()
  def change_plot(plot, attrs) do
    Plot.changeset(plot, attrs)
  end

  @doc """
    list all plots for a  user
  """
  @spec list_user_plots(DataIntrospection.Accounts.User.t(), String.t()) :: [Plot.t()]
  def list_user_plots(user, permission) do
    resource_list = AccessControl.filter_query_based_on_permissions(user, permission)

    Plot
    |> from(as: :plots)
    |> where([p], p.id in ^resource_list)
    |> Repo.all()
  end

  @doc """
    delete plot.
  """
  @spec delete(Plot.t()) :: :ok
  def delete(plot) do
    Repo.delete(plot)
  end

  @doc """
    get plot by id.
  """
  @spec get_plot!(Ecto.UUID.t()) :: Plot.t() | no_return()
  def get_plot!(id) do
    Repo.get!(Plot, id)
  end
end
