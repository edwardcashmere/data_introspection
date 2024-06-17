defmodule DataIntrospection.AccessControl do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias DataIntrospection.Repo

  alias DataIntrospection.Accounts.User
  alias DataIntrospection.Plots.Plot
  alias DataIntrospection.AccessControl.{Policy, Resource, Subject}

  @type anonymous_user :: nil

  @doc "creat policy"
  @spec create_policy(subject :: Subject.t(), resource :: Resource.t(), action :: String.t()) ::
          {:ok, Policy.t()} | {:error, Ecto.Changeset.t()}
  def create_policy(subject, resource, action) do
    attrs = %{
      subject: Subject.code(subject),
      resource: Resource.code(resource),
      action: action
    }

    %Policy{}
    |> Policy.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:subject, :resource, :action])
  end

  @spec check?(
          subject :: Subject.t() | anonymous_user(),
          resource :: Resource.t(),
          action :: atom() | String.t()
        ) ::
          boolean()
  def check?(nil, _resource, :view) do
    false
  end

  def check?(nil, nil, _action), do: false

  def check?(%User{} = subject, %Plot{} = resource, permission) do
    policy_request(subject, resource, permission)
  end

  @spec search_policies(keyword()) :: [Policy.t()]
  def search_policies(options \\ []) do
    Policy
    |> from(as: :policies)
    |> search_policies_query(options)
    |> Repo.all()
  end

  @doc false
  @spec collect_subjects(Subject.t()) :: [Subject.t()]
  def collect_subjects(subject) do
    Subject.collect_subjects(subject)
  end

  @doc false
  @spec collect_resources(Resource.t()) :: [Resource.t()]
  def collect_resources(resource) do
    Resource.collect_resources(resource)
  end

  @doc false
  @spec collect_actions(String.t()) :: [String.t()]
  def collect_actions(action) do
    [action, "*"]
  end

  defp policy_request(subject, resource, action) do
    subjects = collect_subjects(subject)
    resources = collect_resources(resource)
    actions = collect_actions(action)

    [subject: subjects, resource: resources, action: actions]
    |> search_policies()
    |> Enum.any?()
  end

  @spec filter_subject_based_on_permissions(Plot.t()) :: [Ecto.UUID.t()]
  def filter_subject_based_on_permissions(plot) do
    Policy
    |> from(as: :policy)
    |> where([policy: policy], policy.resource == ^Resource.code(plot))
    |> select([p], fragment("split_part(?, '.', 2)", p.subject))
    |> Repo.all()
  end

  @spec filter_query_based_on_permissions(User.t(), String.t()) :: [
          Ecto.UUID.t()
        ]
  def filter_query_based_on_permissions(user, permission) do
    Policy
    |> from(as: :policy)
    |> where([policy: policy], policy.subject == ^Subject.code(user))
    |> where([policy: policy], policy.action == ^permission)
    |> select([p], fragment("split_part(?, '.', 2)", p.resource))
    |> Repo.all()
  end

  @doc "Generates the query used for search policies"
  @spec search_policies_query(Ecto.Queryable.t(),
          subject: [Subject.t()] | nil,
          resource: [Resource.t()] | nil,
          action: [String.t()] | nil
        ) :: Ecto.Query.t()
  def search_policies_query(query, options) do
    options
    |> Keyword.take([:subject, :resource, :action])
    |> Enum.reduce(query, fn
      {:subject, subject}, query ->
        subjects = subject |> List.wrap() |> Enum.map(&Subject.code/1)
        where(query, [policies: p], p.subject in ^subjects)

      {:resource, resource}, query ->
        resources = resource |> List.wrap() |> Enum.map(&Resource.code/1)
        where(query, [policies: p], p.resource in ^resources)

      {:action, action}, query ->
        actions = List.wrap(action)
        where(query, [policies: p], p.action in ^actions)
    end)
  end
end
