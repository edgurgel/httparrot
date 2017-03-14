defmodule HTTParrot.StreamBytesHandlerTest do
  use ExUnit.Case, async: false
  import :meck
  import HTTParrot.StreamBytesHandler

  setup do
    new :cowboy_req
    on_exit fn -> unload() end
    :ok
  end

  test "malformed_request returns true if n is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"a2B=", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"1234", :req3}
        {"chunk_size", :req3, "1024"} -> {"1024", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req4, :state}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if n is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"1234", :req3}
        {"chunk_size", :req3, "1024"} -> {"1024", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req4, {2, 1234, 1024}}

    assert validate :cowboy_req
  end

  test "malformed_request returns true if seed is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"a2B=", :req3}
        {"chunk_size", :req3, "1024"} -> {"1024", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req4, :state}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if seed is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"7", :req3}
        {"chunk_size", :req3, "1024"} -> {"1024", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req4, {2, 7, 1024}}

    assert validate :cowboy_req
  end

  test "malformed_request returns true if chunk_size is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"1234", :req3}
        {"chunk_size", :req3, "1024"} -> {"a2B=", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req4, :state}

    assert validate :cowboy_req
  end

  test "malformed_request returns false if chunk_size is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], {"2", :req2}}])

    expect(:cowboy_req, :qs_val, fn name, req, default ->
      case {name, req, default} do
        {"seed", :req2, "1234"} -> {"1234", :req3}
        {"chunk_size", :req3, "1024"} -> {"13", :req4}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req4, {2, 1234, 13}}

    assert validate :cowboy_req
  end

  test "response must stream chunks" do
    assert {{:chunked, func}, :req1, nil} = get_bytes(:req1, {9, 3, 4})
    assert is_function(func)

    send_func = fn(body) -> send(self(), {:chunk, body}) end
    func.(send_func)

    assert_receive {:chunk, chunk1}
    assert_receive {:chunk, chunk2}
    assert_receive {:chunk, chunk3}

    assert String.length(chunk1) == 4
    assert String.length(chunk2) == 4
    assert String.length(chunk3) == 1
  end
end
