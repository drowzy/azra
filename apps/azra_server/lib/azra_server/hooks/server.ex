defmodule AzraServer.Hooks.Server do
  use GRPC.Server, service: AzraServer.AzraHook.Service

  alias GRPC.Server

  @spec receive_hook(AzraServer.Route.t(), GRPC.Server.Stream.t()) :: any
  def receive_hook(_route, stream) do
    [{AzraServer.Producer, cancel: :transient}]
    |> GenStage.stream()
    |> Stream.map(&AzraServer.AzureHook.new(message: Poison.encode!(&1)))
    |> Enum.each(&Server.stream_send(stream, &1))
  end
end
