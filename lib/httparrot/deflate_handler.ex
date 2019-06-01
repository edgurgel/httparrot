defmodule HTTParrot.DeflateHandler do
  @moduledoc """
  Encode body using deflate encoding
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    zlib = :zlib.open()
    :zlib.deflateInit(zlib)

    {info, req} = GeneralRequestInfo.retrieve(req)
    req = :cowboy_req.set_resp_header("content-encoding", "deflate", req)
    json = response(info) |> JSX.prettify!()
    response = :zlib.deflate(zlib, json, :finish)
    :zlib.deflateEnd(zlib)
    {response, req, state}
  end

  defp response(info) do
    info |> JSX.encode!()
  end
end
