defmodule AzraClient.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{project: rancher_project, url: rancher_url, access_key: ak, secret: secret, selector_key: selector_key}} =
      Confex.fetch_env(:azra_client, :rancher)

    {:ok, %{url: server_url, provider: provider}} = Confex.fetch_env(:azra_client, :server)

    {:ok, channel} = connect(server_url, [])

    children = [
      worker(AzraClient.Consumer, [
        [
          channel: channel,
          dispatcher: AzraClient.Handler.make_handler(selector_key),
          provider: provider
        ]
      ]),
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

  defp connect(hostname, opts), do: GRPC.Stub.connect(hostname, opts)
end
