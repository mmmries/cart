defmodule DashWeb.PageLive do
  use DashWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Dash.PubSub, "voltage")
    {:ok, assign(socket, voltage: "?")}
  end

  @impl true
  def handle_info({:voltage, voltage}, socket) do
    formatted = :io_lib.format('~.1f', [voltage])
    voltage = "#{formatted}v"
    {:noreply, assign(socket, voltage: voltage)}
  end
end
