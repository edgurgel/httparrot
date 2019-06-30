defmodule HTTParrot.SetCookiesHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.SetCookiesHandler

  setup do
    new(:cowboy_req)
    on_exit(fn -> unload() end)
    :ok
  end

  test "malformed_request returns false if /name/value is sent" do
    expect(:cowboy_req, :parse_qs, 1, [])

    expect(:cowboy_req, :binding, [
      {[:name, :req1, nil], "name"},
      {[:value, :req1, nil], "value"}
    ])

    assert malformed_request(:req1, :state) == {false, :req1, [{"name", "value"}]}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns query string values too if /name/value is sent" do
    expect(:cowboy_req, :parse_qs, 1, [{"name", "value2"}])

    expect(:cowboy_req, :binding, [
      {[:name, :req1, nil], "name"},
      {[:value, :req1, nil], "value"}
    ])

    expect(:cowboy_req, :binding, [
      {[:name, :req1, nil], "name"},
      {[:value, :req1, nil], "value"}
    ])

    assert malformed_request(:req1, :state) == {false, :req1, [{"name", "value"}]}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns false if query string values are sent" do
    expect(:cowboy_req, :parse_qs, 1, [{"name", "value"}])
    expect(:cowboy_req, :binding, [{[:name, :req1, nil], nil}])

    assert malformed_request(:req1, :state) == {false, :req1, [{"name", "value"}]}

    assert validate(:cowboy_req)
  end

  test "malformed_request returns true if query string values are not sent" do
    expect(:cowboy_req, :parse_qs, 1, [])
    expect(:cowboy_req, :binding, [{[:name, :req1, nil], nil}])

    assert malformed_request(:req1, :state) == {true, :req1, :state}

    assert validate(:cowboy_req)
  end

  test "redirect to /cookies " do
    expect(:cowboy_req, :set_resp_cookie, [
      {[:k1, :v1, :req1, %{path: "/"}], :req2},
      {[:k2, :v2, :req2, %{path: "/"}], :req3}
    ])

    expect(:cowboy_req, :reply, [
      {[302, %{"location" => "/cookies"}, "Redirecting...", :req3], :req4}
    ])

    assert get_json(:req1, k1: :v1, k2: :v2) == {:stop, :req4, [k1: :v1, k2: :v2]}

    assert validate(:cowboy_req)
  end
end
