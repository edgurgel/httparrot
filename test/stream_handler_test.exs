defmodule HTTParrot.StreamHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.StreamHandler

  setup do
    new :cowboy_req
    new HTTParrot.GeneralRequestInfo
    new JSEX
  end

  teardown do
    unload :cowboy_req
    unload HTTParrot.GeneralRequestInfo
    unload JSEX
  end

  test "malformed_request returns false if it's not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"a2B=", :req2}}])

    assert malformed_request(:req1, :state) == {true, :req2, :state}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if it's an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    assert malformed_request(:req1, :state) == {false, :req2, 2}

    assert validate :cowboy_req
  end

  test "malformed_request returns 1 if 'n' is less than 1" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"0", :req2}}])

    assert malformed_request(:req1, :state) == {false, :req2, 1}

    assert validate :cowboy_req
  end

  test "malformed_request returns 100 if 'n' is greater than 100" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"200", :req2}}])

    assert malformed_request(:req1, :state) == {false, :req2, 100}

    assert validate :cowboy_req
  end

  test "response must stream chunks" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req2})
    expect(JSEX, :encode!, [{[[{:id, 0}, :info]], :json1},
                            {[[{:id, 1}, :info]], :json2}])

    assert {{:chunked, func}, :req2, nil} = get_json(:req1, 2)
    assert is_function(func)

    send_func = fn(body) -> self <- {:chunk, body} end
    func.(send_func)

    assert_receive {:chunk, :json1}
    assert_receive {:chunk, :json2}

    assert validate HTTParrot.GeneralRequestInfo
    assert validate JSEX
  end
end
