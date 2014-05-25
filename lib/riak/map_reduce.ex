defmodule Riak.Mapred do
  import :riakc_pb_socket

  def query(pid, inputs, query), do: mapred(pid, inputs, query)
  def query(pid, inputs, query, timeout), do: mapred(pid, inputs, query, timeout)

  defmodule Bucket do
    def query(pid, bucket, query), do: mapred_bucket(pid, bucket, query)
    def query(pid, bucket, query, timeout), do: mapred_bucket(pid, bucket, query, timeout)
  end
end
