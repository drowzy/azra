
defmodule AzraClient.Rancher do
  defmodule Receiver do
    defstruct id: nil, tag: nil, driver: nil, url: nil, selectors: []

    def new(data) do
      tag = Kernel.get_in(data, ["serviceUpgradeConfig", "tag"])
      selectors =
        data
        |> Kernel.get_in(["serviceUpgradeConfig", "serviceSelector"])
        |> Enum.into([])
        |> Enum.map(fn {_label, value} -> value end)

      %__MODULE__{
        id: data["id"],
        driver: data["driver"],
        url: data["url"],
        tag: tag,
        selectors: selectors,
      }
    end
  end
end
