defmodule Cart.Battery do
  @moduledoc """
  Senses the current voltage of our golf cart battery

  This module knows details of the voltage divider and analog-to-digital conversion
  so we can convert the ADS1115 readings back to actual battery volts
  """

  # we are using a voltage divider of 100kΩ and 5.1kΩ
  @voltage_ratio 105_100.0 / 5_100.0
  # we are measuring relative to GND and 3.3V
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

  def current_voltage(%{bus: bus, addr: addr}) do
    with {:ok, int} <- ADS1115.read(bus, addr, {:ain0, :gnd}, 4096) do
      relative = int / @max_reading
      measured_voltage = @voltage_reference * relative
      inferred_voltage = measured_voltage * @voltage_ratio
      {:ok, inferred_voltage}
    end
  end
end
