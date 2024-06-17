defmodule DataIntrospection.Plots.Plot do
  @moduledoc false

  use DataIntrospection.CommonSchema

  schema "plots" do
    field :title, :string
    field :dataset, :string
    field :expression, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(plot, attrs \\ %{}) do
    plot
    |> cast(attrs, [:title, :dataset, :expression])
    |> validate_required([:title, :dataset, :expression])
  end
end
