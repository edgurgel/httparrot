defmodule HTTParrot.HiddenBasicAuthHandler do
  @moduledoc """
  404'd BasicAuth
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  @doc """
  This method should be `is_authorized`, but this handler will return 404 if the auth fails
  """
  def resource_exists(req, state) do
    {user, req} = :cowboy_req.binding(:user, req)
    {passwd, req} = :cowboy_req.binding(:passwd, req)
    {:ok, auth, req} = :cowboy_req.parse_header("authorization", req)
    case auth do
      {"basic", {^user, ^passwd}} -> {true, req, user}
      _ -> {false, req, state}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, user) do
    {response(user), req, nil}
  end

  defp response(user) do
    [authenticated: true, user: user] |> JSX.encode!
  end
end
