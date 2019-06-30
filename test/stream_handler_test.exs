defmodule HTTParrot.StreamHandlerTest do
  use ExUnit.Case, async: false
  import :meck
  import HTTParrot.StreamHandler

  setup do
    new(:cowboy_req)
    new(HTTParrot.GeneralRequestInfo)
    new(JSX)
    on_exit(fn -> unload() end)
    :ok
  end

  test "malformed_request returns true if it's not an integer" do
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

  test "malformed_request returns 100 if 'n' is greater than 100" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "200"}])

    assert malformed_request(:req1, :state) == {false, :req1, 100}

    assert validate(:cowboy_req)
  end

  test "response must stream chunks" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req2})
    expect(:cowboy_req, :stream_reply, 3, :req2)
    expect(:cowboy_req, :stream_body, 3, :req2)
    expect(JSX, :encode!, [{[[{:id, 0}, :info]], :json1}, {[[{:id, 1}, :info]], :json2}])

    assert {:stop, :req2, nil} = get_json(:req1, 2)

    assert validate(HTTParrot.GeneralRequestInfo)
    assert validate(JSX)
  end
end
