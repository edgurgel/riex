defmodule Riex.CRDT.CounterTest do
  use Riex.Case
  alias Riex.CRDT.Counter

  @moduletag :riak2

  test "create, update and find a counter" do
    key = Riex.Helper.random_key

    Counter.new
      |> Counter.increment
      |> Counter.increment(2)
      |> Riex.update("counter_bucket", "bucketcounter", key)

    counter = Riex.find("counter_bucket", "bucketcounter", key)
      |> Counter.value

    assert counter == 3
  end
end
