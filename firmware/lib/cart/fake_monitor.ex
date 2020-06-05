defmodule Cart.FakeMonitor do
  use GenServer
  require Logger

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @timeout 100

  @impl true
  def init(nil) do
    Scenic.Sensor.register(:battery_level, "1.0", "Battery Level")
    Scenic.Sensor.register(:throttle_level, "1.0", "Throttle Level")
    {:ok, nil, @timeout}
  end

  @impl true
  def handle_info(:timeout, nil) do
    check_battery()
    check_throttle()
    {:noreply, nil, @timeout}
  end

  defp check_battery do
    voltage = (:rand.uniform() * 10.0) + 32.0
    Phoenix.PubSub.broadcast(Dash.PubSub, "voltage", {:voltage, voltage})
    level = (voltage - 32.0) / 10.0
    Scenic.Sensor.publish(:battery_level, level)
  end

  defp check_throttle do
    throttle = :rand.uniform()
    Phoenix.PubSub.broadcast(Dash.PubSub, "throttle", {:throttle, throttle})
    Scenic.Sensor.publish(:throttle_level, throttle)
  end
end
