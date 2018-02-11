defmodule AzraClient.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, channel} = connect("localhost:50051", [])

    children = [
      worker(AzraClient.Consumer, [[channel: channel, dispatcher: &dispatch/1]]),
      worker(AzraClient.Boot, [[provider: "azure"]], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: AzraClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def dispatch(event) do
    IO.puts("In Logger fn #{inspect event}")
  end

  defp connect(hostname, opts), do: GRPC.Stub.connect(hostname, opts)
end
