defmodule Httparrot.Mixfile do
  use Mix.Project

  @description """
    HTTP Request & Response Server. An incomplete clone of http://httpbin.org
  """

  def project do
    [ app: :httparrot,
      version: "0.4.2",
      elixir: "~> 1.2",
      name: "HTTParrot",
      description: @description,
      package: package,
      deps: deps ]
  end

  def application do
    [ applications: [ :compiler,
                      :syntax_tools,
                      :cowboy,
                      :exjsx,
                      :con_cache ],
      mod: { HTTParrot, [] },
      env: [ http_port: 8080, ssl: true, https_port: 8433,
        unix_socket: true, socket_path: "httparrot.sock"] ]
  end

  defp deps do
    [ {:cowboy, "~> 1.0.0"},
      {:exjsx, "~> 3.0"},
      {:con_cache, "~> 0.11.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
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
