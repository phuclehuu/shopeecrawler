defmodule SimpleCacheTest do
  use ExUnit.Case
  doctest SimpleCache

  test "set/2 set cache value" do
    assert SimpleCache.set(:key, :value) == :ok
  end
end
