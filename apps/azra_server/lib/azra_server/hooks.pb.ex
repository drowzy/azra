defmodule AzraServer.Route do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    provider: String.t()
  }
  defstruct [:provider]

  field(:provider, 1, type: :string)
end

defmodule AzraServer.AzureHook do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    message: String.t()
  }
  defstruct [:message]

  field(:message, 1, type: :string)
end

defmodule AzraServer.AzraHook.Service do
  use GRPC.Service, name: "azra_server.AzraHook"

  rpc(:ReceiveHook, AzraServer.Route, stream(AzraServer.AzureHook))
end

defmodule AzraServer.AzraHook.Stub do
  use GRPC.Stub, service: AzraServer.AzraHook.Service
end
