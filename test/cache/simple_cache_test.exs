defmodule SimpleCacheTest do
  use ExUnit.Case
  doctest SimpleCache

  test "set/2 set cache value" do
    key = :key
    assert SimpleCache.set(key, :value, 5) == :ok

    #Wait a bit for set cache already finished
    Process.sleep(1)

    assert SimpleCache.get(%{:table => :simple_cache}, key) == {:ok, :value}
  end

  test "get/2 get cache value" do
    key = :key2

    #Before set: get return {:error, :not_found}
    assert SimpleCache.get(%{:table => :simple_cache}, key) == {:error, :not_found}

    SimpleCache.set(key, :value, 5)

    #Wait a bit for set cache already finished
    Process.sleep(1)

    #After set: get return {:ok, :value}
    assert SimpleCache.get(%{:table => :simple_cache}, key) == {:ok, :value}
  end
end
