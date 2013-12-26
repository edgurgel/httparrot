defmodule HTTParrot.IPHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.IPHandler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "returns prettified json with origin" do
    ip = {127, 1, 2, 3}
    expect(:cowboy_req, :peer, 1, {{ip, :host}, :req2})
    assert get_json(:req1, :state) == {"{\"origin\":\"127.1.2.3\"}", :req2, :state}
    assert validate :cowboy_req
  end
end
