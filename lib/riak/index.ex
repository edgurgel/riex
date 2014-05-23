defmodule Riak.Index do
  def query(bucket, {type, name}, key, opts) do
    case :gen_server.call(:riak, {:index_eq_query, bucket, {type, name}, key, opts}) do
      {:ok, {:index_results_v1, keys, terms, continuation}} -> {keys, terms, continuation}
      res -> res
    end
  end
  def query(bucket, {type, name}, startkey, endkey, opts) do
    case :gen_server.call(:riak, {:index_range_query, bucket, {type, name}, startkey, endkey, opts}) do
      {:ok, {:index_results_v1, keys, terms, continuation}} -> {keys, terms, continuation}
      res -> res
    end
  end
end
