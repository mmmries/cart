defmodule Cart.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    setup_network(target())
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cart.Supervisor]
    children =
      [
        # Children for all targets
        # Starts a worker by calling: Cart.Worker.start_link(arg)
        # {Cart.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Cart.Worker.start_link(arg)
      # {Cart.Worker, arg},
    ]
  end

  def children(_target) do
    [
      {Cart.BatteryMonitor, nil}
    ]
  end

  def setup_network(:host), do: nil

  def setup_network(_) do
    VintageNetWizard.run_wizard
  end

  def target() do
    Application.get_env(:cart, :target)
  end
end
