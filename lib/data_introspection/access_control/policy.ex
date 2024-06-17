defmodule DataIntrospection.AccessControl.Policy do
  @moduledoc """
  The `Policy` entity holds all required information about allowed actions for
  any possible actor. It consists of three attributes: `subject`, `resource` and
  `action` which are self-explaining in Access Control terminology.

  This is a polymorphic table that cannot enforce referential integrity, but granted
  that we default to deny, this is minimally damaging, and just means that our table
  may be larger than necessary.

  ## Resource

  It consists of resource type and its unique identifier:
    - `plots.%{plot_id}`;
    - `user.%{user_id}`;
    - or a wildcard: `*` to allow perform action for all resources.

  ## Action

  It consists of resource type and action type:
    - `edit`;
    - `view`;
    - `view`;
    - `*` (any action);

    - `*` (God mode).
    examples
    | Subject      | Resource | Action |
    | ------------ | -------- | ------ |
    | user.123 | plots.123 | view      |(user 123 has all access all reaource with id 123 of type plot with view action allowed)
    |user.123  | plot.123    | *      | (user 123 has access to resource with id user.123 all action allowed)

  """
  use DataIntrospection.CommonSchema

  schema "policies" do
    field :action, :string
    field :resource, :string
    field :subject, :string

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [:subject, :resource, :action])
    |> validate_required([:subject, :resource, :action])
  end
end
