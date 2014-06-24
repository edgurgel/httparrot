defmodule HTTParrot.DelayedHandler do
  alias HTTParrot.GeneralRequestInfo

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def malformed_request(req, state) do
    {n, req} = :cowboy_req.binding(:n, req)
    try do
      n = n |> String.to_integer |> min(10) |> max(0)
      {false, req, n}
    rescue
      ArgumentError -> {true, req, state}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, n) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    :timer.sleep(n*1000)
    {response(info), req, n}
  end

  defp response(info) do
    info |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
