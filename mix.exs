defmodule Riak.Mixfile do
  use Mix.Project

  def project do
    [ app: :'riak-elixir-client',
      version: "0.0.1",
      elixir: "~> 0.13.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [ :exlager, :pooler ] ]
  end

  defp deps do
    [ {:pooler, github: "seth/pooler"},
      {:exlager, github: "khia/exlager"},
      {:riakc, github: "basho/riak-erlang-client", branch: 'ku-erlang-17-0'}]
  end
end
