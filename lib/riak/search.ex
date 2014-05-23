defmodule Riak.Search do
  def query(bucket, query, options) do
    :gen_server.call(:riak, {:search_query, bucket, query, options})
  end
  def query(bucket, query, options, timeout) do
    :gen_server.call(:riak, {:search_query, bucket, query, options, timeout})
  end

  defmodule Index do
    def list, do: :gen_server.call(:riak, {:search_list_indexes})
    def put(bucket), do: :gen_server.call(:riak, {:search_create_index, bucket})
    def get(bucket), do: :gen_server.call(:riak, {:search_get_index, bucket})
    def delete(bucket), do: :gen_server.call(:riak, {:search_delete_index, bucket})
  end

  defmodule Schema do
    def get(bucket), do: :gen_server.call(:riak, {:search_get_schema, bucket})

    def create(bucket, content) do
      :gen_server.call(:riak, {:search_create_schema, bucket, content})
    end
  end
end
