defmodule AzraReceiver do
  alias AzraReceiver.Dispatcher
  @moduledoc """
  Documentation for AzraReceiver.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AzraReceiver.hello
      :world

  """
  defdelegate register(key, args), to: Dispatcher, as: :register
  defdelegate dispatch(key, type, event), to: Dispatcher, as: :dispatch
end
