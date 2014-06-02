defmodule Riak.Module do
  @moduledoc """
  [EXPERIMENTAL]
  This module changes defmodule to define functions with a
  lower arity for each function so:

  Riak.put(pid, bucket, key, data) ->
  Riak.put(bucket, key, data) that calls the previous function
  with a pid from the pool
  """
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Riak.Module
      import Kernel, except: [defmodule: 2]
    end
  end

  defmacro defmodule(name, block) do
    expanded = Macro.expand(name, __CALLER__)
    quote do
      defmodule unquote(name) do
        unquote(block)
        definitions = Enum.map Module.definitions_in(unquote(expanded), :def), &Riak.Module.define_lower_arity_function/1
        Module.eval_quoted(unquote(expanded), definitions)
      end
    end
  end

  @doc false
  def define_lower_arity_function({func_name, arity}) do
    args = arguments(arity)
    quote do
      def unquote(func_name)(unquote_splicing(args)) do
        pid = :pooler.take_group_member(:riak)
        result = unquote(func_name)(pid, unquote_splicing(args))
        :pooler.return_group_member(:riak, pid, :ok)
        result
      end
    end
  end

  defp arguments(arity) when arity > 1 do
    Enum.map(1..arity-1, &{:"arg#{&1}", [], nil})
  end
  defp arguments(_), do: []
end
