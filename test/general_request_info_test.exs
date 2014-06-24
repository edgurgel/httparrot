defmodule HTTParrot.GeneralRequestInfoTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.GeneralRequestInfo

  setup do
    new :cowboy_req
    on_exit fn -> unload end
    :ok
  end

  doctest HTTParrot.GeneralRequestInfo

  test "returns a list of args, headers, url and original ip" do
    qs_vals = [{"a", "b"}]
    headers = [header1: "value 1", header2: "value 2"]
    ip = {127, 1, 2, 3}
    url = "http://localhost/get?a=b"
    expect(:cowboy_req, :qs_vals, 1, {qs_vals, :req2})
    expect(:cowboy_req, :headers, 1, {headers, :req3})
    expect(:cowboy_req, :url, 1, {url, :req4})
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req5})

    assert retrieve(:req1) == {[args: %{"a" => "b"}, headers: headers, url: url, origin: "127.1.2.3"], :req5}

    assert validate :cowboy_req
  end

  test "returns a list of args with duplicated keys, headers, url and original ip" do
    qs_vals = [{"a", "b"}, {"a", "c"}]
    headers = [header1: "value 1", header2: "value 2"]
    ip = {127, 1, 2, 3}
    url = "http://localhost/get?a=b&a=c"
    expect(:cowboy_req, :qs_vals, 1, {qs_vals, :req2})
    expect(:cowboy_req, :headers, 1, {headers, :req3})
    expect(:cowboy_req, :url, 1, {url, :req4})
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req5})

    assert retrieve(:req1) == {[args: %{"a" => ["b", "c"]}, headers: headers, url: url, origin: "127.1.2.3"], :req5}

    assert validate :cowboy_req
  end

  test "returns a list of empty args, headers, url and original ip" do
    qs_vals = []
    headers = [header1: "value 1", header2: "value 2"]
    ip = {127, 1, 2, 3}
    url = "http://localhost/get"
    expect(:cowboy_req, :qs_vals, 1, {qs_vals, :req2})
    expect(:cowboy_req, :headers, 1, {headers, :req3})
    expect(:cowboy_req, :url, 1, {url, :req4})
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req5})

    assert retrieve(:req1) == {[args: %{}, headers: headers, url: url, origin: "127.1.2.3"], :req5}

    assert validate :cowboy_req
  end
end
