defmodule HTTParrot.DeleteHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.DeleteHandler

  setup do
    new :cowboy_req
    new HTTParrot.GeneralRequestInfo
    new JSEX
    on_exit fn -> unload end
    :ok
  end

  test "returns prettified json with query values, headers, url and origin" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req2})
    expect(JSEX, :encode!, [{[:info], :json}])
    expect(:cowboy_req, :set_resp_body, [{[:json, :req2], :req3}])

    assert delete_resource(:req1, :state) == {true, :req3, :state}

    assert validate :cowboy_req
    assert validate HTTParrot.GeneralRequestInfo
    assert validate JSEX
  end
end
