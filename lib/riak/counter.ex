defmodule Riak.Counter do
  import :riakc_pb_socket

  def enable(pid, bucket), do: Riak.Bucket.put(pid, "#{bucket}-counter", [{:allow_mult, true}])

  def increment(pid, bucket, name, amount) do
    counter_incr(pid, "#{bucket}-counter", name, amount)
  end

  def value(pid, bucket, name) do
    case counter_val(pid, "#{bucket}-counter", name) do
      {:ok, val} -> val
      val -> val
    end
  end
end
