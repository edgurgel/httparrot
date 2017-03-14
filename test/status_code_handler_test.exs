defmodule HTTParrot.StatusCodeHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.StatusCodeHandler

  setup do
    new :cowboy_req
    on_exit fn -> unload() end
    :ok
  end

  test "reply with 'code' as status code" do
    code = 123
    expect(:cowboy_req, :binding, [{[:code, :req1], {code, :req2}}])
    expect(:cowboy_req, :reply, [{[code, [], "", :req2], {:ok, :req3}}])
    assert get_json(:req1, :state) == {:halt, :req3, :state}
    assert validate :cowboy_req
  end
end
