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

    Supervisor.start_link(children(target()), opts)
  end

  def children(:host) do
    [
      {Scenic.Sensor, nil},
      {Cart.FakeMonitor, nil},
      {Scenic, viewports: [main_viewport_config()]}
    ]
  end

  def children(_target) do
    [
      {Scenic.Sensor, nil},
      {Cart.Monitor, nil},
      {Cart.SpeedControl, nil},
      {Scenic, viewports: [main_viewport_config()]}
    ]
  end

  def main_viewport_config do
    Application.get_env(:cart, :viewport)
  end

  def setup_network(:host), do: nil

  def setup_network(_) do
    wifi_configured = VintageNet.configured_interfaces() |> Enum.any?(&(&1 =~ ~r/^wlan/))
    if !wifi_configured do
      VintageNetWizard.run_wizard
    end
  end

  def target() do
    Application.get_env(:cart, :target)
  end
end
