defmodule Cart.BatteryMonitor do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  if Application.get_env(:cart, :target) == :host do
    @battery_module Cart.FakeBattery
  else
    @battery_module Cart.Battery
  end
  @timeout 200

  @impl true
  def init(nil) do
    Scenic.Sensor.register(:battery_level, "1.0", "Battery Level")
    {:ok, batt} = @battery_module.new()
    {:ok, batt, @timeout}
  end

  @impl true
  def handle_info(:timeout, batt) do
    publish_voltage(batt)
    {:noreply, batt, @timeout}
  end

  defp publish_voltage(batt) do
    {:ok, voltage} = @battery_module.current_voltage(batt)
    Phoenix.PubSub.broadcast(Dash.PubSub, "voltage", {:voltage, voltage})
    level = (voltage - 32.0) / 10.0
    Scenic.Sensor.publish(:battery_level, level)
  end
end
