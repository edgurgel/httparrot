defmodule HTTParrot.DeleteCookiesHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.DeleteCookiesHandler

  setup do
    new(:cowboy_req)
    on_exit(fn -> unload() end)
    :ok
  end

  test "delete cookies and redirect to /cookies " do
    expect(:cowboy_req, :set_resp_cookie, [
      {["k1", "v1", :req1, %{path: "/", max_age: 0}], :req2},
      {["k2", "v2", :req2, %{path: "/", max_age: 0}], :req3}
    ])

    expect(:cowboy_req, :reply, [
      {[302, %{"location" => "/cookies"}, "Redirecting...", :req3], :req4}
    ])

    assert get_json(:req1, [{"k1", "v1"}, {"k2", "v2"}]) ==
             {:stop, :req4, [{"k1", "v1"}, {"k2", "v2"}]}

    assert validate(:cowboy_req)
  end
end
