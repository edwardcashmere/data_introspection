defmodule DataIntrospection.CommonSchema do
  @moduledoc "Shared configuration for all schemas"

  defmacro __using__(_opts \\ []) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      # Adds access behavior to each schema
      @behaviour Access

      @impl Access
      defdelegate fetch(resource, key), to: Map

      @impl Access
      defdelegate get_and_update(resource, key, function), to: Map

      @impl Access
      defdelegate pop(resource, key), to: Map

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @type t() :: %__MODULE__{}
    end
  end
end
