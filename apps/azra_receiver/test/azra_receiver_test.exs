defmodule AzraReceiverTest do
  use ExUnit.Case
  doctest AzraReceiver

  test "greets the world" do
    assert AzraReceiver.hello() == :world
  end
end
