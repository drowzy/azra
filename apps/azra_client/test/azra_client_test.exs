defmodule AzraClientTest do
  use ExUnit.Case
  doctest AzraClient

  test "greets the world" do
    assert AzraClient.hello() == :world
  end
end
