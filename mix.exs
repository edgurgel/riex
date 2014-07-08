defmodule Riex.Mixfile do
  use Mix.Project

  def project do
    [ app: :riex,
      version: "0.0.1",
      elixir: "~> 0.14.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [ :exlager, :pooler ] ]
  end

  defp deps do
    [ {:pooler, github: "seth/pooler"},
      {:exlager, github: "khia/exlager"},
      {:riak_pb, github: "basho/riak_pb", override: true, tag: "2.0.0.16", compile: "./rebar get-deps compile deps_dir=../"},
      {:riakc, github: "basho/riak-erlang-client"}]
  end
end
