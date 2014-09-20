defmodule Riex.Mixfile do
  use Mix.Project

  def project do
    [ app: :riex,
      version: "0.0.1",
      elixir: "~> 1.0.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [ :pooler ] ]
  end

  defp deps do
    [ {:pooler, github: "seth/pooler", tag: "1.1.0"},
      {:riak_pb, github: "basho/riak_pb", override: true, tag: "2.0.0.16", compile: "./rebar get-deps compile deps_dir=../"},
      {:riakc, github: "basho/riak-erlang-client"}]
  end
end
