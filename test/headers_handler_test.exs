defmodule HTTParrot.HeadersHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.HeadersHandler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "returns prettified json with headers list" do
    headers = [header1: "value 1", header2: "value 2"]
    expect(:cowboy_req, :headers, 1, {headers, :req2})
    assert get_json(:req1, :state) == {"{\"headers\":{\"header1\":\"value 1\",\"header2\":\"value 2\"}}", :req2, :state}
    assert validate :cowboy_req
  end
end
