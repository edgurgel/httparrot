defmodule Httparrot.Mixfile do
  use Mix.Project

  def project do
    [ app: :httparrot,
      version: "0.3.0",
      name: "HTTParrot",
      elixir: "~> 0.14.1",
      deps: deps ]
  end

  def application do
    [ applications: [ :compiler,
                      :syntax_tools,
                      :cowboy,
                      :jsex ],
      mod: { HTTParrot, [] },
      env: [ http_port: 8080, ssl: true, https_port: 8433 ] ]
  end

  defp deps do
    [ {:cowboy, github: "extend/cowboy", tag: "0.9.0"},
      {:jsex, "~> 2.0"},
      {:meck, github: "eproxus/meck", tag: "0.8.2", only: :test } ]
  end
end
