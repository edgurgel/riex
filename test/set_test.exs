defmodule Riex.CRDT.SetTest do
  use Riex.Case
  alias Riex.CRDT.Set

  @moduletag :riak2

  test "create, update and find a set" do
    key = Riex.Helper.random_key

    Set.new
      |> Set.put("foo")
      |> Set.put("bar")
      |> Riex.update("set_bucket", "bucketset", key)

    set = Riex.find("set_bucket", "bucketset", key)
      |> Set.value

    assert "foo" in set
    assert "bar" in set
  end

  test "size" do
    key = Riex.Helper.random_key

    Set.new
      |> Set.put("foo") |> Set.put("bar")
      |> Set.put("foo") |> Set.put("bar")
      |> Riex.update("set_bucket", "bucketset", key)

    size = Riex.find("set_bucket", "bucketset", key)
      |> Set.size

    assert size == 2
  end
end
