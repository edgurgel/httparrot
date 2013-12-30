defmodule HTTParrot.GetHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.GetHandler

  setup do
    new HTTParrot.GeneralRequestInfo
  end

  teardown do
    unload HTTParrot.GeneralRequestInfo
  end

  test "returns prettified json with query values, headers, url and origin" do
    qs_vals = [{"a", "b"}]
    headers = [header1: "value 1", header2: "value 2"]
    url = "http://localhost/get?a=b"
    ip = "127.1.2.3"
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[args: qs_vals, headers: headers, url: url, origin: ip], :req2})

    assert get_json(:req1, :state) == {"{\"args\":{\"a\":\"b\"},\"headers\":{\"header1\":\"value 1\",\"header2\":\"value 2\"},\"url\":\"http://localhost/get?a=b\",\"origin\":\"127.1.2.3\"}", :req2, :state}

    assert validate HTTParrot.GeneralRequestInfo
  end
end
