defmodule AzraClient.Handler do
  require Logger
  def make_handler(key, decode?), do: &dispatch(key, &1, decode?)

  def dispatch(key, event, true) do
    data =
      event.message
      |> Poison.decode!()
      |> as_docker

    do_dispatch(key, data)
  end

  def dispatch(key, event, _decode?) do
    do_dispatch(key, as_docker(event.message))
  end

  defp do_dispatch(key, data) do
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

  defp as_docker(_event), do: %{}
end
