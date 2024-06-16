defmodule DataIntrospection.Plots do
  @moduledoc """
  The Plots context.
  """

  import Ecto.Query, warn: false

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
    list all plots for a  user
  """
  @spec list_user_plots(DataIntrospection.Accounts.User.t()) :: [Plot.t()]
  def list_user_plots(_user) do
    Repo.all(Plot)
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
