defmodule Cart.Scenes.SysInfo do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font_size: 22, font: :roboto_mono)
    |> Scenic.FuelGauge.Components.fuel_gauge(
      %{gauge_sensor_id: :battery_level},
      [scale: {2.5, 2.5}, translate: {300, 40}]
    )
    |> text(
      "Label",
      id: :battery_label,
      font_size: 30,
      t: {700, 25}
    )
    |> Scenic.FuelGauge.Components.fuel_gauge(
      %{gauge_sensor_id: :throttle_level},
      [scale: {1.5, 1.5}, translate: {25, 25}]
    )
    |> Scenic.Keypad.Components.keypad(
      buttons: [theme: :dark],
      translate: {20, 225},
      scale: 1.5
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
