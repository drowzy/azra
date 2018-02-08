defmodule AzraServer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(AzraServer.HookReceiver, [[]]),
      worker(AzraServer.Producer, [[key: "test"]]),
      worker(AzraServer.Consumer, [])
    ]

    opts = [strategy: :one_for_one, name: AzraServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
