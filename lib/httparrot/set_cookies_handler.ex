defmodule HTTParrot.SetCookiesHandler do
  @moduledoc """
  Sets one or more simple cookies.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    qs_vals = :cowboy_req.parse_qs(req)
    name = :cowboy_req.binding(:name, req, nil)

    if name do
      value = :cowboy_req.binding(:value, req, nil)
      {false, req, List.keystore(qs_vals, name, 0, {name, value})}
    else
      if Enum.empty?(qs_vals), do: {true, req, state}, else: {false, req, qs_vals}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, qs_vals) do
    req =
      Enum.reduce(qs_vals, req, fn {name, value}, req ->
        set_cookie(name, value, req)
      end)

    req = :cowboy_req.reply(302, %{"location" => "/cookies"}, "Redirecting...", req)
    {:stop, req, qs_vals}
  end

  defp set_cookie(name, value, req) do
    :cowboy_req.set_resp_cookie(name, value, req, %{path: "/"})
  end
end
