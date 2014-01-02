defmodule HTTParrot.SetCookiesHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.SetCookiesHandler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "redirect to /cookies " do
    expect(:cowboy_req, :set_resp_cookie, [{[:k1, :v1, [path: "/"], :req1], :req2},
                                           {[:k2, :v2, [path: "/"], :req2], :req3}])
    expect(:cowboy_req, :reply, [{[302, [{"location", "/cookies"}], "Redirecting...", :req3], {:ok, :req4}}])

    assert get_json(:req1, [k1: :v1, k2: :v2]) == {:halt, :req4, [k1: :v1, k2: :v2]}

    assert validate :cowboy_req
  end
end
