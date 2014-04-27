defmodule Httparrot.Mixfile do
  use Mix.Project

  def project do
    [ app: :httparrot,
      version: "0.1.0",
      name: "HTTParrot",
      elixir: "~> 0.13.1",
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
      {:jsex, github: "talentdeficit/jsex", tag: "v1.0.2" } ]
  end

  defp deps(:test) do
    deps(:dev) ++
     [ {:meck, github: "eproxus/meck", ref: "69f02255a8219185bf55da303981d86886b3c24b" } ]
  end

  defp deps(_), do: deps(:dev)
end
