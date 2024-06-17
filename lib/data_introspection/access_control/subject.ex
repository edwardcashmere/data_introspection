defprotocol DataIntrospection.AccessControl.Subject do
  @moduledoc """
  This protocol defines a shape of subject entity in access control terminology
  """

  alias DataIntrospection.Accounts.User
  alias DataIntrospection.Plots.Plot

  @type t() :: User.t() | Plot.t() | String.t()

  @doc """
  Gest subject type
  """
  @spec prefix(t()) :: String.t()
  def prefix(subject)

  @doc """
  Gets subject code
  """
  @spec code(t()) :: String.t()
  def code(subject)

  @doc """
  Returns a list of subjects which particular subject may be included. For example a
  user subject may have many different plots shared and maybe onsume
  global policies
  """
  @spec collect_subjects(t()) :: [t()]
  def collect_subjects(subject)
end

alias DataIntrospection.AccessControl.Subject

defimpl Subject, for: Pclub.Accounts.User do
  def prefix(_user), do: "user."

  def code(user), do: prefix(user) <> user.id

  def collect_subjects(user) do
    [user, "*"]
  end
end

defimpl Subject, for: DataIntrospection.Accounts.User do
  def prefix(_user), do: "user."

  def code(user), do: prefix(user) <> user.id

  def collect_subjects(user) do
    [user, "*"]
  end
end

defimpl Subject, for: DataIntrospection.Plots.Plot do
  def prefix(_organization), do: "plot."

  def code(organization), do: prefix(organization) <> organization.id

  def collect_subjects(plot) do
    [plot, "*"]
  end
end

defimpl Subject, for: BitString do
  def prefix(_string), do: ""
  def code(string), do: string

  def collect_subjects(string) do
    [string]
  end
end
