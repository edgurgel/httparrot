defmodule HTTParrot.HiddenBasicAuthHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.HiddenBasicAuthHandler

  setup do
    new(:cowboy_req)
    new(JSX)
    on_exit(fn -> unload() end)
    :ok
  end

  test "resource_exists returns true if user and passwd match" do
    expect(:cowboy_req, :binding, [
      {[:user, :req1], :user},
      {[:passwd, :req1], :passwd}
    ])

    expect(:cowboy_req, :parse_header, [
      {["authorization", :req1], {:basic, :user, :passwd}}
    ])

    assert resource_exists(:req1, :state) == {true, :req1, :user}

    assert validate(:cowboy_req)
    assert validate(JSX)
  end

  test "resource_exists returns false if user and passwd doesnt match" do
    expect(:cowboy_req, :binding, [{[:user, :req1], :user}, {[:passwd, :req1], :passwd}])

    expect(:cowboy_req, :parse_header, [
      {["authorization", :req1], {:basic, :not_the_user, :passwd}}
    ])

    assert resource_exists(:req1, :state) == {false, :req1, :state}

    assert validate(:cowboy_req)
    assert validate(JSX)
  end

  test "returns user and if it's authenticated" do
    expect(JSX, :encode!, [{[[authenticated: true, user: :user]], :json}])

    assert get_json(:req1, :user) == {:json, :req1, nil}

    assert validate(JSX)
  end
end
