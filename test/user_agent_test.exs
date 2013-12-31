defmodule HTTParrot.UserAgentHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.UserAgentHandler

  setup do
    new :cowboy_req
    new JSEX
  end

  teardown do
    unload :cowboy_req
    unload JSEX
  end

  test "returns prettified json with user agent" do
    expect(:cowboy_req, :header, [{["user-agent", :req1, "null"], {:user_agent, :req2}}])
    expect(JSEX, :encode!, [{[[{"user-agent", :user_agent}]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSEX
  end
end
