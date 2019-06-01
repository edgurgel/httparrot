defmodule HTTParrot.GzipHandler do
  @moduledoc """
  Encode body using gzip encoding
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    req = :cowboy_req.set_resp_header("content-encoding", "gzip", req)
    response = response(info) |> JSX.prettify!() |> :zlib.gzip()
    {response, req, state}
  end

  defp response(info) do
    info |> JSX.encode!()
  end
end
