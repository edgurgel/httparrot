defmodule HTTParrot.DenyHandler do
  @moduledoc """
  Returns a simple HTML page.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

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
    YOU SHOUDN'T BE HERE
  """
  def get_plain(req, state) do
    {@body, req, state}
  end

  def terminate(_, _, _), do: :ok
end
