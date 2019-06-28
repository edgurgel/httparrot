defmodule HTTParrot.StreamBytesHandlerTest do
  use ExUnit.Case, async: false
  import :meck
  import HTTParrot.StreamBytesHandler

  setup do
    new(:cowboy_req)
    on_exit(fn -> unload() end)
    :ok
  end

  test "malformed_request returns true if n is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "a2B="}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "1234"}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "1024"}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req1, :state}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns false if n is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "1234"}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "1024"}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req1, {2, 1234, 1024}}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns true if seed is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "a2B="}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "1024"}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req1, :state}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns false if seed is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "7"}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "1024"}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req1, {2, 7, 1024}}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns true if chunk_size is not an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "1234"}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "a2B="}
      end
    end)

    assert malformed_request(:req1, :state) == {true, :req1, :state}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns false if chunk_size is an integer" do
    expect(:cowboy_req, :binding, [{[:n, :req1], "2"}])

    expect(:cowboy_req, :match_qs, fn [{name, [], default}], req ->
      case {name, req, default} do
        {:seed, :req1, "1234"} -> %{seed: "1234"}
        {:chunk_size, :req1, "1024"} -> %{chunk_size: "13"}
      end
    end)

    assert malformed_request(:req1, :state) == {false, :req1, {2, 1234, 13}}

    assert validate(:cowboy_req)
  end

  test "response must stream chunks" do
    assert {{:chunked, func}, :req1, nil} = get_bytes(:req1, {9, 3, 4})
    assert is_function(func)

    send_func = fn body -> send(self(), {:chunk, body}) end
    func.(send_func)

    assert_receive {:chunk, chunk1}
    assert_receive {:chunk, chunk2}
    assert_receive {:chunk, chunk3}

    assert String.length(chunk1) == 4
    assert String.length(chunk2) == 4
    assert String.length(chunk3) == 1
  end
end
