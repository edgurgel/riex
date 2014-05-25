defmodule Riak.BucketTest do
  use ExUnit.Case
  import RiakHelper

  setup do
    {:ok, pid } = Riak.start_link('127.0.0.1', 8087)
    {:ok, pid: pid}
  end

  teardown context do
    pid = context[:pid]
    clean!(pid)
    :ok
  end

  test "list bucket", context do
    {:ok, buckets} = Riak.Bucket.list context[:pid]
    assert is_list(buckets)
  end

  test "list keys", context do
    {:ok, users} = Riak.Bucket.keys context[:pid], "user"
    assert is_list(users)
  end

  test "bucket props", context do
    pid = context[:pid]
    # Currently there seems to be a bug that returns "Creating new atoms from protobuffs message!"
    assert :ok == Riak.Bucket.put pid, "user", [{:notfound_ok, false}]

    {:ok, props} = Riak.Bucket.get pid, "user"
    assert is_list(props)
    assert props[:notfound_ok] == false

    assert :ok == Riak.Bucket.reset pid, "user"

    {:ok, props} = Riak.Bucket.get pid, "user"
    assert props[:notfound_ok] == true
  end
end
