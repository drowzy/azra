defmodule AzraReceiver.Dispatcher do
  def register(key, args), do: Registry.register(AzraReceiver.Registry, key, args)

  def dispatch(key, type, event) do
    Registry.dispatch(AzraReceiver.Registry, key, fn entries ->
      for {pid, _} <- entries, do: send(pid, {type, event})
    end)
  end
end
