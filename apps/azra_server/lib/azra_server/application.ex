defmodule AzraServer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(AzraReceiver, [[port: 6060, url_base: "hook", key: "registry_push"]]),
      worker(AzraServer.Producer, [[key: "registry_push"]]),
      supervisor(GRPC.Server.Supervisor, [{AzraServer.Hooks.Server, 50051}])
    ]

    opts = [strategy: :one_for_one, name: AzraServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
