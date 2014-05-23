defmodule Riak.Mapred do
  def query(inputs, query), do: :gen_server.call(:riak, {:mapred_query, inputs, query})
  def query(inputs, query, timeout) do
    :gen_server.call(:riak, {:mapred_query, inputs, query, timeout})
  end

  defmodule Bucket do
    def query(bucket, query), do: :gen_server.call(:riak, {:mapred_query_bucket, bucket, query})
    def query(bucket, query, timeout) do
      :gen_server.call(:riak, {:mapred_query_bucket, bucket, query, timeout})
    end
  end
end
