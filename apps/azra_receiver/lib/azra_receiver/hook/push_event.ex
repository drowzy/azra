defmodule AzraReceiver.Hook.PushEvent do
  defstruct id: nil,
            timestamp: nil,
            action: nil,
            target: %{},
            request: %{}

  use ExConstructor

  def as_docker_hub(%__MODULE__{request: request, target: target} = event) do
    push_data = Map.put(%{}, "tag", target["tag"])
    repository = Map.put(%{}, "repo_name", full_name(event))

    %{"push_data" => push_data, "repository" => repository}
  end

  def pretty_print(
        %__MODULE__{
          timestamp: timestamp,
          action: action,
          target: target,
          request: request
        } = event
      ) do
    "#{timestamp} :: Action: #{String.upcase(action)} -> #{full_name(event)}}\nUser-Agent :: #{
      request["useragent"]
    }\nType :: #{target["mediaType"]}\nDigest :: #{target["digest"]} -> #{
      target["size"]
    }"
  end

  defp full_name(%__MODULE__{request: request, target: target}),
    do: "#{request["host"]}/#{target["repository"]}"
end
