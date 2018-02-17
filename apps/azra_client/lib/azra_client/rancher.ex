defmodule AzraClient.Rancher do
  alias AzraClient.Rancher.{Client, Receiver}
  require Logger

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

  def match_on(pid, selector) do
    GenServer.call(pid, {:recievers_matching, selector})
  end

  def exec_match(pid, selector, data) do
    GenServer.call(pid, {:exec_match, selector, data})
  end

  def handle_call({:exec_match, _match}, _from, %{receivers: []} = state), do: {:reply, [], state}

  def handle_call({:exec_match, selector, data}, _from, %{receivers: receivers} = state) do
    res =
      case find_match(receivers, selector) do
        [] ->
          Logger.info("No matches for selector #{inspect(selector)}")
          []

        matches ->
          matches
          |> Task.async_stream(fn %Receiver{id: id, url: url} ->
            Logger.info("Executing hook to receiver id: #{id} -> #{url} #{inspect(data)}")
            Client.post_raw(url, data)
          end)
          |> Enum.map(fn res -> res end)
      end

    {:reply, res, state}
  end

  def handle_call({:recievers_matching, selector}, _from, %{receivers: receivers} = state),
    do: {:reply, find_match(receivers, selector), state}

  def handle_info(:fetch_receivers, %{client: client} = state) do
    Process.send_after(self(), :fetch_receivers, state.fetch_interval)

    case Client.fetch_receivers(client, state.rancher_project) do
      {:ok, %Tesla.Env{body: body}} ->
        receivers = parse_response(body)
        Logger.info("Sync receivers :: Ok -> Setting #{length(receivers)} receivers")

        {:noreply, %{state | receivers: receivers}}

      {:error, error} ->
        Logger.error("Sync receivers :: Error -> #{inspect(error)}")

        {:noreply, state}
    end
  end

  defp parse_response(%{"data" => data}), do: Enum.map(data, &Receiver.new/1)
  defp find_match(receivers, match), do: Enum.filter(receivers, &Receiver.match?(&1, match))
end
