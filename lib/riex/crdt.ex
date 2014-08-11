defmodule Riex.CRDT do
  @moduledoc """
  Common CRDT module
  """
  require Record

  Enum.each [:set, :map, :counter, :register, :flag], fn t ->
    def type(value) when Record.record?(value, unquote(t)), do: unquote(t)
  end
end
