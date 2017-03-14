defmodule HTTParrot.Base64HandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.Base64Handler

  setup do
    new :cowboy_req
    on_exit fn -> unload() end
    :ok
  end

  test "halts with error" do
    expect(:cowboy_req, :binding, [{[:value, :req1], {"I=", :req2}}])

    assert malformed_request(:req1, :state) == {true, :req2, :state}
    assert validate(:cowboy_req)
  end

  test "proceeds with decoded base64 urlsafe" do
    expect(:cowboy_req, :binding, [{[:value, :req1], {"LytiYXNlNjQrLw", :req2}}])

    assert malformed_request(:req1, :state) == {false, :req2, "/+base64+/"}
    assert validate(:cowboy_req)
  end

  test "returns value from state" do
    assert get_binary(:req, :decoded) == {:decoded, :req, :decoded}
  end
end
