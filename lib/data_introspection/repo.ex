defmodule DataIntrospection.Repo do
  use Ecto.Repo,
    otp_app: :data_introspection,
    adapter: Ecto.Adapters.Postgres
end
