defmodule Riak.Bucket do
  import :riakc_pb_socket

  def list(pid), do: list_buckets(pid)
  def list(pid, timeout), do: list_buckets(pid, timeout)

  def list!(pid) do
    {:ok, buckets} = list(pid)
    buckets
  end
  def list!(pid, timeout) do
    {:ok, buckets} = list(pid, timeout)
    buckets
  end

  def keys(pid, bucket), do: list_keys(pid, bucket)
  def keys(pid, bucket, timeout), do: list_keys(pid, bucket, timeout)

  def keys!(pid, bucket) do
    {:ok, keys} = keys(pid, bucket)
    keys
  end
  def keys!(pid, bucket, timeout) do
    {:ok, keys} = keys(pid, bucket, timeout)
    keys
  end

  def get(pid, bucket), do: get_bucket(pid, bucket)
  #Possible Props: [n_val: 3, allow_mult: false, last_write_wins: false, basic_quorum: false, notfound_ok: true, precommit: [], postcommit: [], pr: 0, r: :quorum, w: :quorum, pw: 0, dw: :quorum, rw: :quorum]}

  def put(pid, bucket, props), do: set_bucket(pid, bucket, props)
  def put(pid, bucket, type, props) do
    set_bucket(pid, {type, bucket}, props)
  end

  def reset(pid, bucket), do: reset_bucket(pid, bucket)

  defmodule Type do
    def get(pid, type), do: get_bucket_type(pid, type)
    def put(pid, type, props), do: set_bucket_type(pid, type, props)
    def reset(pid, bucket), do: reset_bucket(pid, bucket)
  end
end
