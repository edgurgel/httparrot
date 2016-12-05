defmodule HTTParrot.DeflateHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.DeflateHandler

  setup do
    new HTTParrot.GeneralRequestInfo
    new JSX
    on_exit fn -> unload end
    :ok
  end

  test "returns prettified json with query values, headers, url and origin" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req2})
    expect(JSX, :encode!, [{[:info], :json}])
    expect(JSX, :prettify!, [{[:json], "json"}])
    expect(:cowboy_req, :set_resp_header, 3, :req3)

    opened_zlib = :zlib.open
    :zlib.deflateInit(opened_zlib)
    body = :zlib.deflate(opened_zlib, "json", :finish)
    :zlib.deflateEnd(opened_zlib)

    assert get_json(:req1, :state) == {body, :req3, :state}

    assert validate HTTParrot.GeneralRequestInfo
    assert validate JSX
    assert validate :cowboy_req
  end
end
