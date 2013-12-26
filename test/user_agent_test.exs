defmodule HTTParrot.UserAgentHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.UserAgentHandler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "returns prettified json with user agent" do
    user_agent = "Mozilla Chrome"
    expect(:cowboy_req, :header, [{["user-agent", :req1, "null"], {user_agent, :req2}}])
    assert get_json(:req1, :state) == {"{\"user-agent\":\"Mozilla Chrome\"}", :req2, :state}
    assert validate :cowboy_req
  end
end
