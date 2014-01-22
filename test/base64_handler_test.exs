defmodule HTTParrot.Base64HandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.Base64Handler

  setup do
    new :cowboy_req
  end

  teardown do
    unload :cowboy_req
  end

  test "returns decoded base64 urlsafe" do
    expect(:cowboy_req, :binding, [{[:value, :req1], {"LytiYXNlNjQrLw", :req2}}])

    assert get_binary(:req1, :state) == { "/+base64+/", :req2, :state}

    assert validate :cowboy_req
  end
end
