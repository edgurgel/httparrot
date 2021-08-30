defmodule HTTParrot.DenyHandler do
  @moduledoc """
  Returns a simple HTML page.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"text", "plain", []}, :get_plain}], req, state}
  end

  @body """
        .-''''''-.
      .' _      _ '.
     /   O      O   \\
    :                :
    |                |
    :       __       :
     \  .-"`  `"-.  /
      '.          .'
        '-......-'
    YOU SHOULDN'T BE HERE
  """
  def get_plain(req, state) do
    {@body, req, state}
  end
end
