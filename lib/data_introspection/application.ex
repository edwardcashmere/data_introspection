defmodule DataIntrospection.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DataIntrospectionWeb.Telemetry,
      DataIntrospection.Repo,
      {DNSCluster, query: Application.get_env(:data_introspection, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DataIntrospection.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DataIntrospection.Finch},
      # Start a worker by calling: DataIntrospection.Worker.start_link(arg)
      # {DataIntrospection.Worker, arg},
      # Start to serve requests, typically the last entry
      DataIntrospectionWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DataIntrospection.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DataIntrospectionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
