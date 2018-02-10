defmodule AzraServer.Route do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    provider: String.t
  }
  defstruct [:provider]

  field :provider, 1, type: :string
end

defmodule AzraServer.AzureHook do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    id:        String.t,
    timestamp: String.t,
    action:    integer,
    target:    AzraServer.AzureHook.Target.t,
    request:   AzraServer.AzureHook.Request.t
  }
  defstruct [:id, :timestamp, :action, :target, :request]

  field :id, 1, type: :string
  field :timestamp, 2, type: :string
  field :action, 3, type: AzraServer.AzureHook.Action, enum: true
  field :target, 4, type: AzraServer.AzureHook.Target
  field :request, 5, type: AzraServer.AzureHook.Request
end

defmodule AzraServer.AzureHook.Target do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    mediaType:  String.t,
    size:       integer,
    repository: String.t,
    tag:        String.t
  }
  defstruct [:mediaType, :size, :repository, :tag]

  field :mediaType, 1, type: :string
  field :size, 2, type: :int32
  field :repository, 3, type: :string
  field :tag, 4, type: :string
end

defmodule AzraServer.AzureHook.Request do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    id:        String.t,
    host:      String.t,
    method:    integer,
    useragent: String.t
  }
  defstruct [:id, :host, :method, :useragent]

  field :id, 1, type: :string
  field :host, 2, type: :string
  field :method, 3, type: AzraServer.AzureHook.Request.Method, enum: true
  field :useragent, 4, type: :string
end

defmodule AzraServer.AzureHook.Request.Method do
  use Protobuf, enum: true, syntax: :proto3

  field :UNKNOWN, 0
  field :GET, 1
  field :POST, 2
  field :PUT, 3
  field :DELETE, 4
end

defmodule AzraServer.AzureHook.Action do
  use Protobuf, enum: true, syntax: :proto3

  field :UNKNOWN, 0
  field :PUSH, 1
  field :DELETE, 2
end

defmodule AzraServer.AzraHook.Service do
  use GRPC.Service, name: "azra_server.AzraHook"

  rpc :ReceiveHook, AzraServer.Route, stream(AzraServer.AzureHook)
end

defmodule AzraServer.AzraHook.Stub do
  use GRPC.Stub, service: AzraServer.AzraHook.Service
end
