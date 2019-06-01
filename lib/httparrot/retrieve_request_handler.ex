defmodule HTTParrot.RetrieveRequestHandler do
  @moduledoc """
  Retreive saved request and clear the conresponding :id
  """
  use HTTParrot.Cowboy, methods: ~w(GET POST PUT HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :retrieve_stored}], req, state}
  end

  def retrieve_stored(req, state) do
    key = :cowboy_req.binding(:key, req)
    requests = HTTParrot.RequestStore.retrieve(key)
    HTTParrot.RequestStore.clear(key)
    {response(requests), req, state}
  end

  defp response(info) do
    info |> JSX.encode!()
  end
end
