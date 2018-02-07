defmodule AzraServerTest do
  use ExUnit.Case
  doctest AzraServer

  test "greets the world" do
    assert AzraServer.hello() == :world
  end
end
