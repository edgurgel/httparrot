defmodule HTTParrot.DelayedHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.DelayedHandler

  setup do
    new(HTTParrot.GeneralRequestInfo)
    new(JSX)
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

  test "malformed_request returns 0 if 'n' is less than 0" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "-1"}])

    assert malformed_request(:req1, :state) == {false, :req1, 0}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns 10 if 'n' is greater than 10" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "20"}])

    assert malformed_request(:req1, :state) == {false, :req1, 10}

    assert validate(:cowboy_req)
  end

  test "returns json with query values, headers, url and origin" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req2})
    expect(JSX, :encode!, [{[:info], :json}])

    assert get_json(:req1, 0) == {:json, :req2, 0}

    assert validate(HTTParrot.GeneralRequestInfo)
    assert validate(JSX)
  end
end
