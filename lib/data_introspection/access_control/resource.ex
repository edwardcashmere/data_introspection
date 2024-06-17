defprotocol DataIntrospection.AccessControl.Resource do
  @moduledoc """
  This protocol defines a shape of resource entity in access control terminology
  """
  alias DataIntrospection.Accounts.User
  alias DataIntrospection.Plots.Plot

  @type t() :: User.t() | Plot.t() | String.t()

  @doc """
  Returns resource prefix
  """
  @spec prefix(t()) :: String.t()
  def prefix(resource)

  @doc """
  Get resource code
  """
  @spec code(t()) :: String.t()
  def code(resource)

  @doc """
  Collects a list of resources for specified resource. In general it's just a resource and
  global selector.
  """
  @spec collect_resources(t()) :: [t()]
  def collect_resources(resource)
end

alias DataIntrospection.AccessControl.Resource

defimpl Resource, for: DataIntrospection.Accounts.User do
  def prefix(_user), do: "user."
  def code(user), do: prefix(user) <> user.id

  def collect_resources(user) do
    [user, "user.*", "*"]
  end
end

defimpl Resource, for: DataIntrospection.Plots.Plot do
  def prefix(_plot), do: "plot."
  def code(plot), do: prefix(plot) <> plot.id

  def collect_resources(plot) do
    [plot, "plot.*", "*"]
  end
end

defimpl Resource, for: BitString do
  def prefix(_string), do: ""
  def code(string), do: string

  def collect_resources(string) do
    case String.split(string, ".") do
      [resource] -> [resource]
      [resource, _] -> [resource, "#{resource}.*", "*"]
    end
  end
end
