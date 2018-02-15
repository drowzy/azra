defmodule AzraClient.Rancher.Receiver do
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

  def match?(%__MODULE__{selectors: selectors}, selector),
    do: Enum.any?(selectors, &(&1 == selector))

  defp parse_selector(nil), do: %{}
  defp parse_selector(selector), do: selector
end
