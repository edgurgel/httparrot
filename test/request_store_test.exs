defmodule HTTParrot.RequestStoreTest do
  alias HTTParrot.RequestStore
  use ExUnit.Case

  test "save, retrieve, clear" do
    request = %{req: 1}
    RequestStore.clear(:test)
    RequestStore.store(:test, request)
    assert RequestStore.retrieve(:test) == [request]
    RequestStore.clear(:test)
    assert RequestStore.retrieve(:test) == []
  end
end
