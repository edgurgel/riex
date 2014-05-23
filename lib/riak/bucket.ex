defmodule Riak.Bucket do
  def list, do: :gen_server.call(:riak, {:list_buckets})
  def list(timeout), do: :gen_server.call(:riak, {:list_buckets, timeout})

  def keys(bucket), do: :gen_server.call(:riak, {:list_keys, bucket})
  def keys(bucket, timeout), do: :gen_server.call(:riak, {:list_keys, bucket, timeout})

  def get(bucket), do: :gen_server.call(:riak, {:props, bucket})
  #Possible Props: [n_val: 3, allow_mult: false, last_write_wins: false, basic_quorum: false, notfound_ok: true, precommit: [], postcommit: [], pr: 0, r: :quorum, w: :quorum, pw: 0, dw: :quorum, rw: :quorum]}

  def put(bucket, props), do: :gen_server.call(:riak, {:set_props, bucket, props})
  def put(bucket, type, props), do: :gen_server.call(:riak, {:set_props, bucket, type, props})

  def reset(bucket), do: :gen_server.call(:riak, {:reset, bucket})

  defmodule Type do
    def get(type), do: :gen_server.call(:riak, {:get_type, type})
    def put(type, props), do: :gen_server.call(:riak, {:set_type, type, props})
    def reset(type), do: :gen_server.call(:riak, {:reset_type, type})
  end
end
