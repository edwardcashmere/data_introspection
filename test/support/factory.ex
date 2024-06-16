defmodule DataIntrospectionWeb.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: DataIntrospection.Repo

  def user_factory do
    %DataIntrospection.Accounts.User{
      email: build(:email),
      hashed_password: build(:hashed_password)
    }
  end

  def email_factory(_), do: sequence(:email, &"email-#{&1}@cytely.com")
  def password_factory(_), do: "password1234"
  def hashed_password_factory(_), do: Bcrypt.hash_pwd_salt(password_factory(nil))

  @spec extract_user_token((any -> any)) :: String.t()
  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
