defmodule HTTParrot.DeleteHandler do
  @moduledoc """
  Returns DELETE data.
  """
  alias HTTParrot.GeneralRequestInfo

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["DELETE"], req, state}
  end

  def delete_resource(req, state) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    req = :cowboy_req.set_resp_body(response(info), req)
    {true, req, state}
  end

  defp response(info) do
    info |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
