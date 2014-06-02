use Riak.Module
defmodule Riak.Bucket do
  import :riakc_pb_socket

  def list(pid) when is_pid(pid), do: list_buckets(pid)
  def list(pid, timeout) when is_pid(pid), do: list_buckets(pid, timeout)

  def list!(pid) when is_pid(pid) do
    {:ok, buckets} = list(pid)
    buckets
  end
  def list!(pid, timeout) when is_pid(pid) do
    {:ok, buckets} = list(pid, timeout)
    buckets
  end

  def keys(pid, bucket) when is_pid(pid), do: list_keys(pid, bucket)
  def keys(pid, bucket, timeout) when is_pid(pid), do: list_keys(pid, bucket, timeout)

  def keys!(pid, bucket) when is_pid(pid) do
    {:ok, keys} = keys(pid, bucket)
    keys
  end
  def keys!(pid, bucket, timeout) when is_pid(pid) do
    {:ok, keys} = keys(pid, bucket, timeout)
    keys
  end

  def get(pid, bucket) when is_pid(pid), do: get_bucket(pid, bucket)

  def put(pid, bucket, props) when is_pid(pid), do: set_bucket(pid, bucket, props)
  def put(pid, bucket, type, props) when is_pid(pid) do
    set_bucket(pid, {type, bucket}, props)
  end

  def reset(pid, bucket) when is_pid(pid), do: reset_bucket(pid, bucket)

  # This is important to "register" the atoms
  defp possible_props do
    [n_val: 3, old_vclock: 86400, young_vclock: 20, big_vclock: 50, small_vclock: 50, allow_mult: false, last_write_wins: false,
      basic_quorum: false, notfound_ok: false, precommit: [], postcommit: [], chash_keyfun: {:riak_core_util, :chash_std_keyfun},
      linkfun: {:modfun, :riak_kv_wm_link_walker, :mapreduce_linkfun}, pr: 0, r: :quorum, w: :quorum, pw: 0, dw: :quorum,
      rw: :quorum]
  end
end
defmodule Riak.Bucket.Type do
  import :riakc_pb_socket
  def get(pid, type) when is_pid(pid), do: get_bucket_type(pid, type)
  def put(pid, type, props) when is_pid(pid), do: set_bucket_type(pid, type, props)
  def reset(pid, bucket) when is_pid(pid), do: reset_bucket(pid, bucket)
end

