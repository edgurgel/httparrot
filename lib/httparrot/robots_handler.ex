defmodule HTTParrot.RobotsHandler do
  @moduledoc """
  Returns a robots.txt.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"text", "plain", []}, :get_text}], req, state}
  end

  @robots """
  User-agent: *
  Disallow: /deny
  """

  def get_text(req, state), do: {@robots, req, state}

  def terminate(_, _, _), do: :ok
end
