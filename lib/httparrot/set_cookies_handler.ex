defmodule HTTParrot.SetCookiesHandler do
  @moduledoc """
  Sets one or more simple cookies.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def malformed_request(req, state) do
    {qs_vals, req} = :cowboy_req.qs_vals(req)
    if Enum.empty?(qs_vals), do: {true, req, state}, else: {false, req, qs_vals}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, qs_vals) do
    req = Enum.reduce qs_vals, req, fn({name, value}, req) ->
      set_cookie(name, value, req)
    end
    {:ok, req} = :cowboy_req.reply(302, [{"location", "/cookies"}], "Redirecting...", req)
    {:halt, req, qs_vals}
  end

  defp set_cookie(name, value, req) do
    :cowboy_req.set_resp_cookie(name, value, [path: "/"], req)
  end

  def terminate(_, _, _), do: :ok
end
