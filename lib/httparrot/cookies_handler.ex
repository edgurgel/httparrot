defmodule HTTParrot.CookiesHandler do
  @moduledoc """
  Returns cookie data.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {cookies, req} = :cowboy_req.cookies(req)
    if cookies == [], do: cookies = [{}]
    {response(cookies), req, state}
  end

  defp response(cookies) do
    [cookies: cookies] |> JSEX.encode!
  end
end
