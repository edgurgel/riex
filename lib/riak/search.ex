defmodule Riak.Search do
  import :riakc_pb_socket

  def query(pid, bucket, query, options), do: search(pid, bucket, query, options)
  def query(pid, bucket, query, options, timeout), do: search(pid, bucket, query, options, timeout)

  defmodule Index do
    def list(pid), do: list_search_indexes(pid)
    def put(pid, bucket), do: create_search_index(pid, bucket)
    def get(pid, bucket), do: get_search_index(pid, bucket)
    def delete(pid, bucket), do: delete_search_index(pid, bucket)
  end

  defmodule Schema do
    def get(pid, bucket), do: get_search_schema(pid, bucket)

    def create(pid, bucket, content) do
      create_search_schema(pid, bucket, content)
    end
  end
end
