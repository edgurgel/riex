defmodule Riex.CRDT.MapTest do
  require IEx
  use Riex.Case
  alias Riex.CRDT.Map
  alias Riex.CRDT.Register
  alias Riex.CRDT.Flag
  alias Riex.CRDT.Counter
  alias Riex.CRDT.Set

  @moduletag :riak2

  test "create, update and find a map with other CRDTs" do
    key = Riex.Helper.random_key

    reg_data = "Register data"
    reg = Register.new(reg_data)
    reg_key = "register_key"

    flag = Flag.new |> Flag.enable
    flag_key = "flag_key"

    counter = Counter.new |> Counter.increment
    counter_key = "counter_key"

    set = Set.new |> Set.put("foo")
    set_key = "set_key"

    Map.new
      |> Map.update(reg_key, reg)
      |> Map.update(flag_key, flag)
      |> Map.update(counter_key, counter)
      |> Map.update(set_key, set)
      |> Riex.update("map_bucket", "bucketmap", key)

    map = Riex.find("map_bucket", "bucketmap", key)
      |> Map.value

    map_keys = :orddict.fetch_keys(map)
    assert {"counter_key", :counter} in map_keys
    assert {"flag_key", :flag} in map_keys
    assert {"register_key", :register} in map_keys
    assert {"set_key", :set} in map_keys

    assert :orddict.size(map) == 4

    data = :orddict.to_list(map)
    assert {{reg_key, :register}, reg_data} in data
    assert {{flag_key, :flag}, true} in data
    assert {{counter_key, :counter}, 1} in data
    assert {{set_key, :set}, ["foo"]} in data
  end

  test "create, update and find nested maps" do
    key = Riex.Helper.random_key

    flag = Flag.new |> Flag.enable
    flag_key = "flag_key"
    nested = Map.new |> Map.update(flag_key, flag)
    nested_key = "nested_key"

    Map.new
      |> Map.update(nested_key, nested)
      |> Riex.update("map_bucket", "bucketmap", key)

    map = Riex.find("map_bucket", "bucketmap", key)

    value_map = map |> Map.value

    assert :orddict.size(value_map) == 1

    assert :orddict.fetch({"nested_key", :map}, value_map) == [{{"flag_key", :flag}, true}]
    IEx.pry
  end
end
