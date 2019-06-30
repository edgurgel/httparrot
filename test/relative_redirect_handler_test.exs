defmodule HTTParrot.RelativeRedirectHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.RelativeRedirectHandler

  setup do
    new(:cowboy_req)
    on_exit(fn -> unload() end)
    :ok
  end

  test "malformed_request returns false if it's not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "a2B="}])

    assert malformed_request(:req1, :state) == {true, :req1, :state}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns false if it's an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    assert malformed_request(:req1, :state) == {false, :req1, 2}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns 1 if 'n' is less than 1" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "0"}])

    assert malformed_request(:req1, :state) == {false, :req1, 1}

    assert validate(:cowboy_req)
  end

  test "moved_permanently returns 'redirect/n-1' if n > 1" do
    assert moved_permanently(:req1, 4) == {{true, "/redirect/3"}, :req1, nil}
  end

  test "moved_permanently returns '/get' if n = 1" do
    assert moved_permanently(:req1, 1) == {{true, "/get"}, :req1, nil}
  end
end
