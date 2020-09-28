defmodule ThemaVerbi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ThemaVerbi.Worker.start_link(arg)
      # {ThemaVerbi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThemaVerbi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
