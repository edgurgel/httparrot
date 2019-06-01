defmodule HTTParrot.UserAgentHandler do
  @moduledoc """
  Returns user-agent.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {user_agent, req} = :cowboy_req.header("user-agent", req, "null")
    {response(user_agent), req, state}
  end

  defp response(user_agent) do
    [{"user-agent", user_agent}]
    |> JSX.encode!()
  end
end
