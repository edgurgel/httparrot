defmodule HTTParrot.CacheHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.CacheHandler

  setup do
    new(HTTParrot.GeneralRequestInfo)
    new(JSX)
    on_exit(fn -> unload() end)
    :ok
  end

  test "returns prettified json with query values, headers, url and origin" do
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {:info, :req2})
    expect(JSX, :encode!, [{[:info], :json}])

    assert get_json(:req1, :state) == {:json, :req2, :state}

    assert validate(HTTParrot.GeneralRequestInfo)
    assert validate(JSX)
  end
end
