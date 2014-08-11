defmodule Riex.CRDT.Register do
  @moduledoc """
  Encapsulates a binary data to be used on CRDT.Map's
  """
  require Record

  @doc """
  Creates a new register
  """
  def new, do: :riakc_register.new

  @doc """
  Creates a new register with the initial `value`
  """
  def new(value) when is_binary(value), do: set(new, value)

  @doc """
  Extracts current value of `register`
  """
  def value(register) when Record.record?(register, :register) do
    :riakc_register.value(register)
  end

  @doc """
  Set the `value` on the `register`
  """
  def set(register, value) when Record.record?(register, :register)
                           and is_binary(value) do
    :riakc_register.set(value, register)
  end
end
