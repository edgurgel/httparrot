defmodule HTTParrot.CookiesHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.CookiesHandler

  setup do
    new :cowboy_req
    new JSEX
  end

  teardown do
    unload :cowboy_req
    unload JSEX
  end

  test "returns a JSON with all the cookies o/" do
    expect(:cowboy_req, :cookies, 1, {[k1: :v1], :req2})
    expect(JSEX, :encode!, [{[[cookies: [k1: :v1]]], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate :cowboy_req
    assert validate JSEX
  end
end
