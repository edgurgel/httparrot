defmodule HTTParrot.UserAgentHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.UserAgentHandler

  setup do
    new :cowboy_req
    new JSX
    on_exit fn -> unload() end
    :ok
  end

  test "returns prettified json with user agent" do
    expect(:cowboy_req, :header, [{["user-agent", :req1, "null"], :user_agent}])
    expect(JSX, :encode!, [{[[{"user-agent", :user_agent}]], :json}])

    assert get_json(:req1, :state) == {:json, :req1, :state}

    assert validate :cowboy_req
    assert validate JSX
  end
end
