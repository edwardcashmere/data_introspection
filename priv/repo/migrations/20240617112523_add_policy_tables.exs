defmodule DataIntrospection.Repo.Migrations.AddPolicyTables do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:policies, primary: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string, null: false
      add :resource, :string, null: false
      add :action, :string, null: false

      timestamps()
    end

    create unique_index(:policies, [:subject, :resource, :action])
  end
end
