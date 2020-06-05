defmodule Cart.Monitor do
  use GenServer
  require Logger
  alias Cart.{Battery, Throttle}

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # It seems to take ~9ms to I2C read, so this should be
  # reading sensors every ~33ms
  @timeout 15

  @impl true
  def init(nil) do
    Scenic.Sensor.register(:battery_level, "1.0", "Battery Level")
    Scenic.Sensor.register(:throttle_level, "1.0", "Throttle Level")
    {:ok, i2c} = Circuits.I2C.open("i2c-1")
    {:ok, %{i2c: i2c}, @timeout}
  end

  @impl true
  def handle_info(:timeout, %{i2c: i2c} = state) do
    check_battery(i2c)
    check_throttle(i2c)
    {:noreply, state, @timeout}
  end

  defp check_battery(bus) do
    {:ok, voltage} = Battery.current_voltage(bus)
    Phoenix.PubSub.broadcast(Dash.PubSub, "voltage", {:voltage, voltage})
    level = (voltage - 32.0) / 10.0
    Scenic.Sensor.publish(:battery_level, level)
  end

  defp check_throttle(bus) do
    {:ok, throttle} = Throttle.current_throttle(bus)
    Phoenix.PubSub.broadcast(Dash.PubSub, "throttle", {:throttle, throttle})
    Scenic.Sensor.publish(:throttle_level, throttle)
  end
end
