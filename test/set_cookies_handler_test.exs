defmodule HTTParrot.SetCookiesHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.SetCookiesHandler

  setup do
    new :cowboy_req
    on_exit fn -> unload end
    :ok
  end

  test "malformed_request returns false if /name/value is sent" do
    expect(:cowboy_req, :qs_vals, 1, {[], :req2})
    expect(:cowboy_req, :binding, [{[:name, :req2, nil], {"name", :req3}},
                                   {[:value, :req3, nil], {"value", :req4}}])

    assert malformed_request(:req1, :state) == {false, :req4, [{"name", "value"}]}

    assert validate :cowboy_req
  end

  test "malformed_request returns query string values too if /name/value is sent" do
    expect(:cowboy_req, :qs_vals, 1, {[{"name", "value2"}], :req2})
    expect(:cowboy_req, :binding, [{[:name, :req2, nil], {"name", :req3}},
                                   {[:value, :req3, nil], {"value", :req4}}])

    assert malformed_request(:req1, :state) == {false, :req4, [{"name", "value"}]}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if query string values are sent" do
    expect(:cowboy_req, :qs_vals, 1, {[{"name", "value"}], :req2})
    expect(:cowboy_req, :binding, [{[:name, :req2, nil], {nil, :req3}}])

    assert malformed_request(:req1, :state) == {false, :req3, [{"name", "value"}]}

    assert validate :cowboy_req
  end

  test "malformed_request returns true if query string values are not sent" do
    expect(:cowboy_req, :qs_vals, 1, {[], :req2})
    expect(:cowboy_req, :binding, [{[:name, :req2, nil], {nil, :req3}}])

    assert malformed_request(:req1, :state) == {true, :req3, :state}

    assert validate :cowboy_req
  end

  test "redirect to /cookies " do
    expect(:cowboy_req, :set_resp_cookie, [{[:k1, :v1, [path: "/"], :req1], :req2},
                                           {[:k2, :v2, [path: "/"], :req2], :req3}])
    expect(:cowboy_req, :reply, [{[302, [{"location", "/cookies"}], "Redirecting...", :req3], {:ok, :req4}}])

    assert get_json(:req1, [k1: :v1, k2: :v2]) == {:halt, :req4, [k1: :v1, k2: :v2]}

    assert validate :cowboy_req
  end
end
