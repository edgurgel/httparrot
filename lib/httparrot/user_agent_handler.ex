defmodule HTTParrot.UserAgentHandler do
  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {user_agent, req} = :cowboy_req.header("user-agent", req, "null")
    {response(user_agent), req, state}
  end

  defp response(user_agent) do
    [{"user-agent", user_agent}]
    |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
