ExUnit.start

defmodule RiakHelper do
  def clean!(pid) do
    for bucket <- Riak.Bucket.list!(pid), key <- Riak.Bucket.keys!(pid, bucket) do
      Riak.delete(pid, bucket, key)
    end
  end
end
