defmodule HTTParrot.HeadersHandler do
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {headers, req} = :cowboy_req.headers(req)
    {response(headers), req, state}
  end

  defp response(headers) do
    [headers: headers] |> JSEX.encode!
  end
end
