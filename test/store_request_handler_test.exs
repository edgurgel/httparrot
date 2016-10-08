defmodule HTTParrot.StoreRequestHandlerTests do
  use ExUnit.Case
  import :meck
  import HTTParrot.StoreRequestHandler

  setup do
    HTTParrot.RequestStore.clear(:test)
    on_exit fn -> unload end
    :ok
  end

  test "store a request" do
    expect(:cowboy_req, :binding, [:key, :req1], {:test, :req1})
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req1})
    assert get(:req1, :state) == {'{"saved":  "true"}', :req1, :state}
    assert HTTParrot.RequestStore.retrieve(:test) == [:info]
  end

  test "store multiple requests" do
    expect(:cowboy_req, :binding, [:key, :req1], {:test, :req1})
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req1})
    assert get(:req1, :state) == {'{"saved":  "true"}', :req1, :state}
    assert get(:req2, :state) == {'{"saved":  "true"}', :req1, :state}
    assert HTTParrot.RequestStore.retrieve(:test) == [:info, :info]
  end
end
