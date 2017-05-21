defmodule HTTParrot.IPHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.IPHandler

  setup do
    new :cowboy_req
    new JSX
    on_exit fn -> unload() end
    :ok
  end

  test "returns prettified json with origin" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})
    expect(:cowboy_req, :parse_header, 2, {:ok, :undefined, :req2})
    expect(JSX, :encode!, [{[[origin: "127.1.2.3"]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSX
  end

  test "returns prettified json with client ip when available" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})
    expect(:cowboy_req, :parse_header, 2, {:ok, ["190.1.2.3"], :req2})
    expect(JSX, :encode!, [{[[origin: "190.1.2.3"]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSX
  end

  test "returns empty when running over unix sockets" do
    expect(:cowboy_req, :peer, 1, {{:local, ""}, :req2})
    expect(:cowboy_req, :parse_header, 2, {:ok, :undefined, :req2})
    expect(JSX, :encode!, [{[[origin: ""]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSX
  end
end
