defmodule Cart.SpeedControl do
  use GenServer
  require Logger

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # if we ever go more than this number of milliseconds without
  # getting a throttle update, we should shut down the speed control
  @timeout 200

  @impl true
  def init(nil) do
    Phoenix.PubSub.subscribe(Dash.PubSub, "throttle")
    {:ok, nil, @timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    set_speed_control(0.0)
    {:noreply, state, @timeout}
  end

  def handle_info({:throttle, throttle}, state) do
    set_speed_control(throttle)
    {:noreply, state, @timeout}
  end

  def handle_info(other, state) do
    Logger.error("#{__MODULE__} received unexpected message: #{inspect(other)}")
    {:noreply, state}
  end

  # ratio is a floating point number between 0.0 and 1.0
  defp set_speed_control(ratio) do
    duty_cycle = trunc(ratio * 1_000_000)
    Pigpiox.Pwm.hardware_pwm(18, 10_000, duty_cycle)
  end
end
