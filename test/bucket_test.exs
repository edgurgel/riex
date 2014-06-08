defmodule Riex.BucketTest do
  use Riex.Case

  test "list bucket", context do
    {:ok, buckets} = Riex.Bucket.list context[:pid]
    assert is_list(buckets)
  end

  test "list! bucket", context do
    buckets = Riex.Bucket.list! context[:pid]
    assert is_list(buckets)
  end

  test "list keys", context do
    {:ok, keys} = Riex.Bucket.keys context[:pid], "user"
    assert is_list(keys)
  end

  test "list! keys", context do
    keys = Riex.Bucket.keys! context[:pid], "user"
    assert is_list(keys)
  end

  test "bucket props", context do
    pid = context[:pid]
    assert :ok == Riex.Bucket.put pid, "user", [{:notfound_ok, false}]

    {:ok, props} = Riex.Bucket.get pid, "user"
    assert is_list(props)
    assert props[:notfound_ok] == false

    assert :ok == Riex.Bucket.reset pid, "user"

    {:ok, props} = Riex.Bucket.get pid, "user"
    assert props[:notfound_ok] == true
  end
end
