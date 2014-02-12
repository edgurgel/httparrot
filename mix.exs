defmodule Httparrot.Mixfile do
  use Mix.Project

  def project do
    [ app: :httparrot,
      version: "0.0.3",
      name: "HTTParrot",
      elixir: "~> 0.12.4",
      deps: deps(Mix.env) ]
  end

  def application do
    [ applications: [ :compiler,
                      :syntax_tools,
                      :cowboy,
                      :jsex ],
      mod: { HTTParrot, [] },
      env: [ http_port: 8080, ssl: true, https_port: 8433 ] ]
  end

  defp deps(:dev) do
    [ {:cowboy, github: "extend/cowboy", tag: "0.9.0" },
      {:jsex, github: "talentdeficit/jsex" } ]
  end

  defp deps(:test) do
    deps(:dev) ++
     [ {:meck, github: "eproxus/meck", tag: "0.8.1" } ]
  end

  defp deps(_), do: deps(:dev)
end
