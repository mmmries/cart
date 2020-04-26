defmodule Cart.BatteryMonitor do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @timeout 500

  @impl true
  def init(nil) do
    {:ok, batt} = Cart.Battery.new()
    {:ok, batt, @timeout}
  end

  @impl true
  def handle_info(:timeout, batt) do
    {:ok, voltage} = Cart.Battery.current_voltage(batt)
    Phoenix.PubSub.broadcast(Dash.PubSub, "voltage", {:voltage, voltage})
    {:noreply, batt, @timeout}
  end
end
