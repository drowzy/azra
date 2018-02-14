defmodule AzraClient.Rancher.Client do
  use Tesla

  alias AzraClient.Rancher.Receiver

  plug(Tesla.Middleware.Tuples)
  plug(Tesla.Middleware.JSON)

  def fetch_receivers(client, project_id) do
    get(client, "/v1-webhooks/receivers?limit=-1&projectId=#{project_id}")
  end

  def client(base_url, {access_key, secret}) do
    Tesla.build_client([
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, %{"Authorization" => "#{access_key}=#{secret}"}}
    ])
  end
end
