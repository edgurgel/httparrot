defmodule HTTParrot.GetHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.GetHandler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "returns prettified json with query values, headers, url and origin" do
    qs_vals = [{"a", "b"}]
    headers = [header1: "value 1", header2: "value 2"]
    ip = {127, 1, 2, 3}
    url = "http://localhost/get?a=b"
    expect(:cowboy_req, :qs_vals, 1, {qs_vals, :req2})
    expect(:cowboy_req, :headers, 1, {headers, :req2})
    expect(:cowboy_req, :url, 1, {url, :req2})
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})

    assert get_json(:req1, :state) == {"{\"args\":{\"a\":\"b\"},\"headers\":{\"header1\":\"value 1\",\"header2\":\"value 2\"},\"url\":\"http://localhost/get?a=b\",\"origin\":\"127.1.2.3\"}", :req2, :state}

    assert validate :cowboy_req
  end

  test "returns prettified json with no query value, headers, url and origin" do
    qs_vals = []
    headers = [header1: "value 1", header2: "value 2"]
    ip = {127, 1, 2, 3}
    url = "http://localhost/get"
    expect(:cowboy_req, :qs_vals, 1, {qs_vals, :req2})
    expect(:cowboy_req, :headers, 1, {headers, :req2})
    expect(:cowboy_req, :url, 1, {url, :req2})
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})

    assert get_json(:req1, :state) == {"{\"args\":{},\"headers\":{\"header1\":\"value 1\",\"header2\":\"value 2\"},\"url\":\"http://localhost/get\",\"origin\":\"127.1.2.3\"}", :req2, :state}

    assert validate :cowboy_req
  end
end
