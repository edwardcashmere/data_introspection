defmodule DataIntrospection.Repo.Migrations.AddPlotsMigration do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:plots, primary: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :dataset, :string, null: false
      add :expression, :string, null: false

      timestamps()
    end
  end
end
