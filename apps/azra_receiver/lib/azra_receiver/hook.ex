defmodule AzraReceiver.Hook do
  require Logger

  alias AzraReceiver.Handler.Helpers
  alias AzraReceiver.Hook.PushEvent

  def init(req, state), do: handle(req, state)

  def handle(%{method: "POST"} = req, state) do
    {body, req} = Helpers.decode_body(req)

    event = PushEvent.new(body)

    Logger.info("Hook triggered #{:cowboy_req.uri(req)}\n#{PushEvent.pretty_print(event)}")

    {result, req} = respond(req, 200, PushEvent.as_docker_hub(event))
    {result, req, state}
  end

  def handle(req, state) do
    Logger.info("Received unsupported method #{:cowboy_req.method(req)} -> #{inspect :cowboy_req.headers(req)}")

    {result, req} = respond(req, 418, %{"error" => "action #{:cowboy_req.method(req)} not supported"})
    {result, req, state}
  end


  defp respond(req, status, body) do
    req
    |> Helpers.set_headers(content_type())
    |> Helpers.set_body(body)
    |> Helpers.respond(status)
  end

  defp content_type, do: %{"Content-type" => "application/json"}
end
