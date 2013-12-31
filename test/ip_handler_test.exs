defmodule HTTParrot.IPHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.IPHandler

  setup do
    new :cowboy_req
    new JSEX
  end

  teardown do
    unload :cowboy_req
    unload JSEX
  end

  test "returns prettified json with origin" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})
    expect(JSEX, :encode!, [{[[origin: "127.1.2.3"]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSEX
  end
end
