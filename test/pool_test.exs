defmodule Riex.PoolTest do
  use Riex.Case
  import Riex.Helper

  test "put" do
    key = random_key

    o =  Riex.Object.create(bucket: "user", key: key, data: "Drew Kerrigan")

    assert Riex.put(o) == o
  end
end
