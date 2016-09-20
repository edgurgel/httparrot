defmodule HTTParrot.RetrieveRequestHandlerTests do
  use ExUnit.Case
  import :meck
  import HTTParrot.RetrieveRequestHandler

  setup do
    HTTParrot.RequestStore.clear(:test)
    :ok
  end

  test "returns saved requests" do
    expect(JSX, :encode!, [{[:req1], :json}])
    expect(:cowboy_req, :binding, [:key, :req1], {:test, :req1})
    HTTParrot.RequestStore.store(:test, :req1)
    assert retrieve_stored(:req1, :state) == {:json, :req1, :state}
  end
end
