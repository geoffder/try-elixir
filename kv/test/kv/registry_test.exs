defmodule KV.RegistryTest do
  use ExUnit.Case

  setup do
    # rather than using Registry's start_link/1, use the start_supervised!/2
    # function (optional initial state value is second arg, default: [])
    # injected by ExUnit.Case. This ensures that the service is stopped before
    # running the next test (great in case they access the same things).
    registry = start_supervised!(KV.Registry)
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

    # the bucket works?
    KV.Bucket.put(bucket, "dark souls", 1)
    assert KV.Bucket.get(bucket, "dark souls") == 1

    # non-existent name returns :error on lookup
    assert KV.Registry.lookup(registry, "shopping") == :error

    # returns list of all names in the registry
    assert KV.Registry.list_names(registry) == ["cart", "wishlist"]
  end

  test "removes buckets on exit", %{registry: registry} do
    # create bucket and stop it
    KV.Registry.create(registry, "cart")
    {:ok, bucket} = KV.Registry.lookup(registry, "cart")
    Agent.stop(bucket)

    # check that "cart" no longer exists
    assert KV.Registry.lookup(registry, "cart") == :error
  end
end
