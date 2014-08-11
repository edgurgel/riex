defmodule Riex.CRDTTest do
  use ExUnit.Case
  import Riex.CRDT

  test 'type of Register' do
    assert type(Riex.CRDT.Register.new) == :register
  end

  test 'type of Set' do
    assert type(Riex.CRDT.Set.new) == :set
  end

  test 'type of Map' do
    assert type(Riex.CRDT.Map.new) == :map
  end

  test 'type of Flag' do
    assert type(Riex.CRDT.Flag.new) == :flag
  end

  test 'type of Counter' do
    assert type(Riex.CRDT.Counter.new) == :counter
  end
end
