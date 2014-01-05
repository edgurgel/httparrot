defmodule HTTParrot.StatusCodeHandler do
  @moduledoc """
  Returns given HTTP Status code.
  """

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
    {code, req} = :cowboy_req.binding(:code, req)
    {:ok, req} = :cowboy_req.reply(code, [], "", req)
    {:halt, req, state}
  end

  def terminate(_, _, _), do: :ok
end
