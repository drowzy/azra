defmodule AzraReceiver do
  alias AzraReceiver.Dispatcher
  require Logger

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    port = Keyword.get(args, :port, 6060)
    url_base = Keyword.get(args, :url_base, "hook")
    subscription_key = Keyword.get(args, :key, "key")

    Logger.info("Started Hook relay on port #{port}")

    children = [
      {Registry, keys: :duplicate, name: AzraReceiver.Registry},
      %{
        id: :cowboy,
        start: {
          :cowboy,
          :start_clear,
          [:http_listener, [port: port], %{env: %{dispatch: router_config(url_base, subscription_key)}}]
        }
      }
    ]

    opts = [strategy: :one_for_one, name: AzraReceiver.Supervisor]

    Supervisor.init(children, opts)
  end

  defdelegate register(key, args), to: Dispatcher, as: :register
  defdelegate dispatch(key, type, event), to: Dispatcher, as: :dispatch

  defp router_config(url_base, subscription_key) do
    :cowboy_router.compile([
      {:_,
       [
         {"/#{url_base}", AzraReceiver.Hook, %{cb: &AzraReceiver.Dispatcher.dispatch/3, key: subscription_key}}
       ]}
    ])
  end
end
