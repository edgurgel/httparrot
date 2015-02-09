defmodule Httparrot.Mixfile do
  use Mix.Project

  @description """
    HTTP Request & Response Server. An incomplete clone of http://httpbin.org
  """

  def project do
    [ app: :httparrot,
      version: "0.3.5",
      elixir: "~> 1.0",
      name: "HTTParrot",
      description: @description,
      package: package,
      deps: deps ]
  end

  def application do
    [ applications: [ :compiler,
                      :syntax_tools,
                      :cowboy,
                      :exjsx ],
      mod: { HTTParrot, [] },
      env: [ http_port: 8080, ssl: true, https_port: 8433 ] ]
  end

  defp deps do
    [ {:cowboy, "~> 1.0.0"},
      {:exjsx, "~> 3.0"},
      {:meck, "~> 0.8.2", only: :test } ]
  end

  defp package do
    [ contributors: ["Eduardo Gurgel Pinho"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/edgurgel/httparrot",
                "HTTParrot" => "http://httparrot.herokuapp.com",
                "httpbin" => "http://httpbin.org" } ]
  end
end
