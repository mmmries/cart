defmodule Cart.Scenes.SysInfo do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @target System.get_env("MIX_TARGET") || "host"

  @system_info """
  MIX_TARGET: #{@target}
  MIX_ENV: #{Mix.env()}
  Scenic version: #{Scenic.version()}
  """

  @graph Graph.build(font_size: 22, font: :roboto_mono)
    |> group(
      fn g ->
        g
        |> text("System")
        |> text(@system_info, translate: {10, 20}, font_size: 18)
      end,
      t: {10, 30}
    )
    |> Scenic.FuelGauge.Components.fuel_gauge(
      %{gauge_sensor_id: :battery_level},
      [scale: {3.0, 3.0}, translate: {80, 40}]
    )
    |> text(
      "Label",
      id: :battery_label,
      t: {360, 400}
    )

  def init(_, _opts) do
    Phoenix.PubSub.subscribe(Dash.PubSub, "voltage")
    {:ok, @graph, push: @graph}
  end

  def handle_info({:voltage, voltage}, graph) do
    formatted = :io_lib.format('~.1f', [voltage])
    voltage = "#{formatted}v"
    graph = Graph.modify(graph, :battery_label, &text(&1, voltage))
    {:noreply, graph, push: graph}
  end
end
