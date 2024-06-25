defmodule Httparrot.Mixfile do
  use Mix.Project

  @source_url "https://github.com/edgurgel/httparrot"
  @version "1.4.0"

  def project do
    [
      app: :httparrot,
      version: @version,
      elixir: "~> 1.16",
      name: "HTTParrot",
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HTTParrot, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.12"},
      {:exjsx, "~> 3.0 or ~> 4.0"},
      {:con_cache, "~> 1.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.18", only: :dev},
      {:meck, "~> 0.9", only: :test}
    ]
  end

  defp package do
    [
      description: "https://github.com/edgurgel/httparrot",
      maintainers: ["Eduardo Gurgel Pinho"],
      licenses: ["MIT"],
      links: %{
        "Github" => @source_url,
        "HTTParrot" => "http://httparrot.herokuapp.com",
        "httpbin" => "http://httpbin.org"
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
