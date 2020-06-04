defmodule Cart.ThrottleMonitor do
  use GenServer
  require Logger

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  if Application.get_env(:cart, :target) == :host do
    @throttle_module Cart.FakeThrottle
  else
    @throttle_module Cart.Throttle
  end
  @timeout 50

  @impl true
  def init(nil) do
    Scenic.Sensor.register(:throttle_level, "1.0", "Throttle Level")
    {:ok, state} = @throttle_module.new()
    {:ok, state, @timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    publish_voltage(state)
    {:noreply, state, @timeout}
  end

  defp publish_voltage(state) do
    {:ok, throttle} = @throttle_module.current_throttle(state)
    Phoenix.PubSub.broadcast(Dash.PubSub, "throttle", {:throttle, throttle})
    Scenic.Sensor.publish(:throttle_level, throttle)
  end
end
