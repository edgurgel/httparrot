defmodule HTTParrot.CookiesHandler do
  @moduledoc """
  Returns cookie data.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {cow_cookies, req} = :cowboy_req.cookies(req)
    cookies = if cow_cookies == [] do [{}] else cow_cookies end
    {response(cookies), req, state}
  end

  defp response(cookies) do
    [cookies: cookies] |> JSX.encode!
  end
end
