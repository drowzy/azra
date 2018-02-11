defmodule AzraClient.Consumer do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    channel = Keyword.get(opts, :channel, nil)
    dispatcher = Keyword.get(opts, :dispatcher, fn args -> args end)

    {:ok,
     %{
       channel: channel,
       dispatcher: dispatcher
     }}
  end

  def receive_stream(pid, provider),
    do: GenServer.cast(pid, {:receive_stream, provider})

  def handle_cast(
        {:receive_stream, provider},
        %{channel: channel, dispatcher: dispatcher} = state
      ) do
    req = AzraServer.Route.new(provider: provider)

    Logger.info("Requesting Hook stream with provider #{provider}")

    :ok = channel
      |> AzraServer.AzraHook.Stub.receive_hook(req)
      |> Task.async_stream(&(dispatcher.(&1)))
      |> Stream.run()

    {:noreply, state}
  end
end
