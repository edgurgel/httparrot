defmodule HTTParrot.GzipHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.GzipHandler

  setup do
    new(HTTParrot.GeneralRequestInfo)
    new(HTTParrot.JSON)
    on_exit(fn -> unload() end)
    :ok
  end

  test "returns prettified json with query values, headers, url and origin" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req2})
    expect(HTTParrot.JSON, :encode!, [{[:info], :json}])
    expect(HTTParrot.JSON, :prettify!, [{[:json], "json"}])
    expect(:cowboy_req, :set_resp_header, 3, :req3)

    body = :zlib.gzip("json")

    assert get_json(:req1, :state) == {body, :req3, :state}

    assert validate(HTTParrot.GeneralRequestInfo)
    assert validate(HTTParrot.JSON)
    assert validate(:cowboy_req)
  end
end
