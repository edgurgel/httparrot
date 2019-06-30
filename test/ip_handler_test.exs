defmodule HTTParrot.IPHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.IPHandler

  setup do
    new(:cowboy_req)
    new(JSX)
    on_exit(fn -> unload() end)
    :ok
  end

  test "returns prettified json with origin" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {ip, 0})
    expect(:cowboy_req, :parse_header, 2, :undefined)
    expect(JSX, :encode!, [{[[origin: "127.1.2.3"]], :json}])

    assert get_json(:req1, :state) == {:json, :req1, :state}

    assert validate(:cowboy_req)
    assert validate(JSX)
  end

  test "returns prettified json with client ip when available" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {ip, 0})
    expect(:cowboy_req, :parse_header, 2, ["190.1.2.3"])
    expect(JSX, :encode!, [{[[origin: "190.1.2.3"]], :json}])

    assert get_json(:req1, :state) == {:json, :req1, :state}

    assert validate(:cowboy_req)
    assert validate(JSX)
  end

  test "returns empty when running over unix sockets" do
    expect(:cowboy_req, :peer, 1, {{127, 0, 0, 1}, 0})
    expect(:cowboy_req, :parse_header, 2, :undefined)
    expect(JSX, :encode!, [{[[origin: ""]], :json}])

    assert get_json(:req1, :state) == {:json, :req1, :state}

    assert validate(:cowboy_req)
    assert validate(JSX)
  end
end
