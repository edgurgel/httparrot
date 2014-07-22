defmodule HTTParrot.RobotsHandler do
  @moduledoc """
  Returns a robots.txt.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"text", "plain", []}, :get_text}], req, state}
  end

  @robots """
  User-agent: *
  Disallow: /deny
  """

  def get_text(req, state), do: {@robots, req, state}
end
