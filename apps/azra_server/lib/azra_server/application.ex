defmodule AzraServer.Application do
  @moduledoc
  """
  Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(AzraServer.HookReceiver, [[]]),
    ]

    opts = [strategy: :one_for_one, name: AzraServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
