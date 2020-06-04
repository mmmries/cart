defmodule Cart.FakeThrottle do
  def new do
    {:ok, nil}
  end

  def current_throttle(nil) do
    throttle = :crypto.rand_uniform(0, 100) / 100.0
    {:ok, throttle}
  end
end
