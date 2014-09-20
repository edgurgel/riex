defmodule Riex.CRDT.Map do
  @moduledoc """
  Encapsulates Riak maps
  """
  require Record

  @doc """
  Creates a new `map`
  """
  def new, do: :riakc_map.new

  @doc """
  Get the `map` size
  """
  def size(map) when Record.is_record(map, :map), do: :riakc_map.size(map)

  @doc """
  Fetch the value associated to `key` with the `key_type` on `map`
  """
  def get(map, key_type, key) when Record.is_record(map, :map) do
    :riakc_map.fetch({key, key_type}, map)
  end

  @doc """
  Update the `key` on the `map` by passing the function `fun`
  to update the value based on the current value (if exists) as argument
  The key_type must be :register, :map, :set, :flag or :counter
  """
  def update(map, key_type, key, fun) when Record.is_record(map, :map)
                                      and is_atom(key_type)
                                      and is_binary(key)
                                      and is_function(fun, 1) do

    :riakc_map.update({key, key_type}, fun, map)
  end

  @doc """
  Update the `key` on the `map` by passing the `value`
  The value can be any other CRDT
  """
  def put(map, key, value) when Record.is_record(map, :map)
                              and is_binary(key) do
    key_type = Riex.CRDT.type(value)
    fun = fn _ -> value end
    :riakc_map.update({key, key_type}, fun, map)
  end

  @doc """
  Delete a `key` from the `map`
  """
  def delete(map, key) when Record.is_record(map, :map) and is_binary(key) do
    :riakc_map.erase(key, map)
  end

  @doc """
  Get the original value of the `map`
  """
  def value(map) when Record.is_record(map, :map), do: :riakc_map.value(map)

  @doc """
  List all keys of the `map`
  """
  def keys(map) when Record.is_record(map, :map), do: :riakc_map.fetch_keys(map)

  @doc """
  Test if the `key` is contained in the `map`
  """
  def has_key?(map, key) when Record.is_record(map, :map) and is_binary(key) do
    :riakc_map.is_key(key, map)
  end
end
