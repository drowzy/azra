defmodule AzraClient.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{project: rancher_project, url: rancher_url, access_key: ak, secret: secret, mode: mode} = rancher_conf} =
      Confex.fetch_env(:azra_client, :rancher)

    children =
      children_by_mode(mode, rancher_conf) ++
        [
          worker(AzraClient.Rancher, [
            [
              rancher_url: rancher_url,
              rancher_project: rancher_project,
              rancher_credentials: {ak, secret}
            ]
          ])
        ]

    opts = [strategy: :one_for_one, name: AzraClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children_by_mode(mode, conf) when is_binary(mode), do: children_by_mode(String.to_atom(mode), conf)

  defp children_by_mode(:mixed, %{selector_key: key}) do
    dispatch_key = "registry_push"

    [
      Supervisor.Spec.supervisor(AzraReceiver, [[port: 6060, url_base: "hook", key: dispatch_key]]),
      Supervisor.Spec.worker(AzraClient.Receiver, [[key: dispatch_key, dispatcher: AzraClient.Handler.make_handler(key, false) ]])
    ]
  end

  defp children_by_mode(_, %{selector_key: key}) do
    {:ok, %{url: server_url, provider: provider}} = Confex.fetch_env(:azra_client, :server)
    {:ok, channel} = GRPC.Stub.connect(server_url, [])

    [
      Supervisor.Spec.worker(AzraClient.Consumer, [
        [
          channel: channel,
          dispatcher: AzraClient.Handler.make_handler(key, true),
          provider: provider
        ]
      ])
    ]
  end
end
