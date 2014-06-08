defmodule Riex.CounterTest do
  use Riex.Case

  @counter_key "my_counter"

  test "increment", context do
    pid = context[:pid]

    assert :ok == Riex.Counter.enable(pid, "user")
    assert :ok == Riex.Counter.increment(pid, "user", @counter_key, 1)
    assert 1 == Riex.Counter.value(pid, "user", @counter_key)
  end

  test "decrement", context do
    pid = context[:pid]

    assert :ok == Riex.Counter.enable(pid, "user")
    assert :ok == Riex.Counter.increment(pid, "user", @counter_key, -1)
    assert -1 == Riex.Counter.value(pid, "user", @counter_key)
  end

end
