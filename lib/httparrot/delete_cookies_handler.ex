defmodule HTTParrot.DeleteCookiesHandler do
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
      delete_cookie(name, value, req)
    end
    {:ok, req} = :cowboy_req.reply(302, [{"location", "/cookies"}], "Redirecting...", req)
    {:halt, req, qs_vals}
  end

  defp delete_cookie(name, true, req), do: delete_cookie(name, "", req)
  defp delete_cookie(name, value, req) do
    :cowboy_req.set_resp_cookie(name, value, [path: "/", max_age: 0], req)
  end

  def terminate(_, _, _), do: :ok
end
