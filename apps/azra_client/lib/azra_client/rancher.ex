defmodule AzraClient.Rancher do
  alias AzraClient.Rancher.{Client, Receiver}
  require Logger

  defmodule Receiver do
    defstruct id: nil, tag: nil, driver: nil, url: nil, selectors: []

    def new(data) do
      tag = Kernel.get_in(data, ["serviceUpgradeConfig", "tag"])

      selectors =
        data
        |> Kernel.get_in(["serviceUpgradeConfig", "serviceSelector"])
        |> parse_selector
        |> Enum.into([])

      %__MODULE__{
        id: data["id"],
        driver: data["driver"],
        url: data["url"],
        tag: tag,
        selectors: selectors
      }
    end

    defp parse_selector(nil), do: %{}
    defp parse_selector(selector), do: selector
  end

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    rancher_url = Keyword.get(opts, :rancher_url, nil)
    rancher_credential = Keyword.get(opts, :rancher_credentials, nil)
    rancher_project = Keyword.get(opts, :rancher_project, nil)
    fetch_interval = Keyword.get(opts, :fetch_interval, 10000)

    client = Client.client(rancher_url, rancher_credential)

    Process.send_after(self(), :fetch_receivers, 0)

    {:ok,
     %{
       receivers: [],
       client: client,
       rancher_project: rancher_project,
       fetch_interval: fetch_interval
     }}
  end

  def handle_info(:fetch_receivers, %{client: client} = state) do
    case Client.fetch_receivers(client, state.rancher_project) do
      {:ok, %Tesla.Env{body: body}} ->
        Logger.info("Req: Ok -> #{inspect(parse_response(body))}")

      {:error, error} ->
        Logger.error("Req: Error -> #{inspect(error)}")
    end

    Process.send_after(self(), :fetch_receivers, state.fetch_interval)

    {:noreply, state}
  end

  defp parse_response(%{"data" => data}), do: Enum.map(data, &Receiver.new/1)
end
