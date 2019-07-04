defmodule KV.BucketTest do
  # async options makes the test run in parellel with other test cases
  # (speeds up out test suite. Don't use if global state is being modified)
  use ExUnit.Case, async: true

  # this callback macro is called by the test macro, so a new bucket agent
  # is created before every test
  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  @doc """
  Test macro brough in by ExUnit.Case. ExUnit merges the map returned by
  the setup callback in to the 'test context'. We can pattern match the bucket
  value out of the 'test context' map.
  e.g. %{test: a} = %{a: 5, test: 3, foo: "bar"} -> a = 3
  """
  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    assert KV.Bucket.delete(bucket, "milk") == 3  # return value of deleted key
    assert KV.Bucket.delete(bucket, "milk") == nil  # check that it is gone
  end
end
