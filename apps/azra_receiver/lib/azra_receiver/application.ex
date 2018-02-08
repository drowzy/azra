defmodule AzraReceiver.Application do
  @moduledoc """
  Application
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, _} =
      :cowboy.start_clear(:http_listener, [port: 8080], %{
        env: %{dispatch: router_config()}
      })

    children = [
      {Registry, keys: :duplicate, name: AzraReceiver.Registry}
    ]

    opts = [strategy: :one_for_one, name: AzraReceiver.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp router_config do
    :cowboy_router.compile([
      {:_,
       [
         {"/hook", AzraReceiver.Hook, %{cb: &AzraReceiver.Dispatcher.dispatch/3, key: "test"}}
       ]}
    ])
  end
end
