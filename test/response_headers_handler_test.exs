defmodule HTTParrot.ResponseHeadersHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.ResponseHeadersHandler

  setup do
    new :cowboy_req
    on_exit fn -> unload end
    :ok
  end

  test "malformed_request returns true if query string is empty" do
    expect(:cowboy_req, :qs_vals, 1, {[], :req2})

    assert malformed_request(:req1, :state) == {true, :req2, :state}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if query string is not empty" do
    expect(:cowboy_req, :qs_vals, 1, {[{"foo", "bar"}], :req2})

    assert malformed_request(:req1, :state) == {false, :req2, [{"foo", "bar"}]}

    assert validate :cowboy_req
  end

  test "query string parameters are sent as headers" do
    expect(:cowboy_req, :set_resp_header, [{[:k1, :v1, :req1], :req2},
                                           {[:k2, :v2, :req2], :req3}])

    assert get_json(:req1, [k1: :v1, k2: :v2]) == {"", :req3, [k1: :v1, k2: :v2]}

    assert validate :cowboy_req
  end
end
