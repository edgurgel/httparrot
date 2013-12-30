defmodule HTTParrot.GetHandler do
  alias HTTParrot.GeneralRequestInfo

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
    {info, req} = GeneralRequestInfo.retrieve(req)
    {response(info), req, state}
  end

  defp response(info) do
    info |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
