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
      {:riakc, github: "basho/riak-erlang-client"}]
  end
end
