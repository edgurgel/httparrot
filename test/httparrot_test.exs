defmodule HTTParrotTest do
  use ExUnit.Case
  import :meck
  import HTTParrot

  setup do
    new(:cowboy_req)
    on_exit(fn -> unload() end)
    :ok
  end

  test "'prettify_json' prettifies body response if it's a JSON" do
    expect(:cowboy_req, :reply, [
      {[:status, %{"content-length" => '14'}, "{\n  \"a\": \"b\"\n}", :req1], :req2}
    ])

    assert prettify_json(:status, %{"content-length" => '12'}, "{\"a\":\"b\"}", :req1) == :req2
    assert validate(:cowboy_req)
  end

  test "'prettify_json' does nothing if body is not a JSON" do
    assert prettify_json(:status, :headers, "<xml></xml>", :req1) == :req1
  end
end
