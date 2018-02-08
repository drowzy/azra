defmodule AzraServer.Consumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(_) do
    {:consumer, :ok, subscribe_to: [AzraServer.Producer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect({self(), Poison.encode!(event), state})
    end

    {:noreply, [], state}
  end
end
