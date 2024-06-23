defmodule HTTParrot.RetrieveRequestHandlerTests do
  use ExUnit.Case
  import :meck
  import HTTParrot.RetrieveRequestHandler

  setup do
    HTTParrot.RequestStore.clear(:test)
    on_exit(fn -> unload() end)
    :ok
  end

  test "returns saved requests" do
    expect(:cowboy_req, :binding, [:key, :req1], {:test, :req1})
    HTTParrot.RequestStore.store(:test, :req1)
    assert retrieve_stored(:req1, :state) == {"[\"req1\"]", :req1, :state}
  end
end
