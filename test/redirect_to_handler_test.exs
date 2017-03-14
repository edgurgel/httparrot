defmodule HTTParrot.RedirectToHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.RedirectToHandler

  setup do
    new :cowboy_req
    on_exit fn -> unload() end
    :ok
  end

  test "malformed_request returns true if no 'url' is defined" do
    expect(:cowboy_req, :qs_val, [{["url", :req1, nil], {:url, :req2}}])
    assert malformed_request(:req1, :state) == {false, :req2, :url}
    assert validate :cowboy_req
  end

  test "malformed_request returns false if no 'url' is defined" do
    expect(:cowboy_req, :qs_val, [{["url", :req1, nil], {nil, :req2}}])
    assert malformed_request(:req1, :state) == {true, :req2, :state}
    assert validate :cowboy_req
  end
end
