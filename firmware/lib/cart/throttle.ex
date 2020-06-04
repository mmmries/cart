defmodule Cart.Throttle do
  @moduledoc """
  Senses the throttle input

  This module monitors a potentionmeter that provides a signal between 0 and 3.3v
  """

  # we are measuring relative to GND and 4.096V
  @voltage_reference 4.096
  # ADS1115 returns a signed 16bit number, so the maximum possible value is 2^15
  @max_reading 32768.0

  def new() do
    with {:ok, bus} <- Circuits.I2C.open("i2c-1") do
      map = %{
        bus: bus,
        addr: 72
      }
      {:ok, map}
    end
  end

  # the magnetic sensor we are using starts at 1/2 reference voltage
  # it ramps up to the reference voltage as the magnetic field gets stronger.
  # The reference voltage in this case is 3.3v and it never ramps to full strength.
  # So in this case we consider anything less than 1.7v to be 0 throttle
  # and anything over 2.8v to be 100% throttle
  def current_throttle(state) do
    with {:ok, voltage} <- current_voltage(state) do
      relative = (voltage - 1.5) / 1.3
      throttle = clamp(relative)
      {:ok, throttle}
    end
  end

  def current_voltage(%{bus: bus, addr: addr}) do
    with {:ok, int} <- ADS1115.read(bus, addr, {:ain1, :gnd}, 4096) do
      relative = int / @max_reading
      measured_voltage = @voltage_reference * relative
      {:ok, measured_voltage}
    end
  end

  defp clamp(value) when value < 0.0, do: 0.0
  defp clamp(value) when value > 1.0, do: 1.0
  defp clamp(value), do: value
end
