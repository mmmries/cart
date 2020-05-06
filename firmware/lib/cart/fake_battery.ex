defmodule Cart.FakeBattery do
  def new do
    {:ok, nil}
  end

  def current_voltage(nil) do
    voltage = :crypto.rand_uniform(320, 420) / 10.0
    {:ok, voltage}
  end
end
