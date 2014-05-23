defmodule Riak.Counter do
  def enable(bucket), do: Riak.Bucket.put("#{bucket}-counter", [{:allow_mult, true}])

  def increment(bucket, name, amount) do
    :gen_server.call(:riak, {:counter_incr, "#{bucket}-counter", name, amount})
  end

  def value(bucket, name) do
    case :gen_server.call(:riak, {:counter_val, "#{bucket}-counter", name}) do
      {:ok, val} -> val
      val -> val
    end
  end
end
