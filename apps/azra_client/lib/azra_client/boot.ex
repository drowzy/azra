defmodule AzraClient.Boot do
  use Task

  def start_link(opts \\ []) do
    Task.start_link(__MODULE__, :run, [opts])
  end

  def run(opts) do
    provider = Keyword.get(opts, :provider, "azure")
    AzraClient.Consumer.receive_stream(AzraClient.Consumer, provider)
  end
end
