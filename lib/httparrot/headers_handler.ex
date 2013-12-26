defmodule HTTParrot.HeadersHandler do
  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {headers, req} = :cowboy_req.headers(req)
    {response(headers), req, state}
  end

  defp response(headers) do
    [headers: headers]
    |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
