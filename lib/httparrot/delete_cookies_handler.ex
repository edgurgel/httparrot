defmodule HTTParrot.DeleteCookiesHandler do
  @moduledoc """
  Deletes one or more simple cookies.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    qs_vals = :cowboy_req.parse_qs(req)
    if Enum.empty?(qs_vals), do: {true, req, state}, else: {false, req, qs_vals}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, qs_vals) do
    req =
      Enum.reduce(qs_vals, req, fn {name, value}, req ->
        delete_cookie(name, value, req)
      end)

    req = :cowboy_req.reply(302, %{"location" => "/cookies"}, "Redirecting...", req)
    {:stop, req, qs_vals}
  end

  defp delete_cookie(name, true, req), do: delete_cookie(name, "", req)

  defp delete_cookie(name, value, req) do
    :cowboy_req.set_resp_cookie(name, value, req, %{path: "/", max_age: 0})
  end
end
