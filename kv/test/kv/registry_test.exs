defmodule KV.RegistryTest do
  use ExUnit.Case

  setup do
    {:ok, registry} = KV.Registry.start_link([])
    %{registry: registry}
  end

  test "registers processes", %{registry: registry} do
    # create a bucket process named "cart"
    KV.Registry.create(registry, "cart")
    # attempting to create existing process does nothing (no error)
    KV.Registry.create(registry, "cart")
    # new bucket process
    KV.Registry.create(registry, "wishlist")

    # lookup returns {:ok, pid} for existing bucket
    assert {:ok, bucket} = KV.Registry.lookup(registry, "cart")
    # non-existent name returns :error on lookup
    assert KV.Registry.lookup(registry, "shopping") == :error
    # returns list of all names in the registry
    assert KV.Registry.list_names(registry) == ["cart", "wishlist"]
  end
end
