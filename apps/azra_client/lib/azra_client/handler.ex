defmodule AzraClient.Handler do
  require Logger
  def make_handler(key), do: &dispatch(key, &1)

  def dispatch(key, event) do
    data =
      event.message
      |> Poison.decode!()
      |> as_docker

    value = Kernel.get_in(data, ["repository", "repo_name"])

    AzraClient.Rancher.exec_match(AzraClient.Rancher, {key, value}, data)
  end

  defp as_docker(%{"request" => request, "target" => target}) do
    %{
      "push_data" => %{
        "tag" => target["tag"]
      },
      "repository" => %{
        "repo_name" => "#{request["host"]}/#{target["repository"]}"
      }
    }
  end

  defp as_docker(event), do: %{}
end
