defmodule HTTParrot.DelayedHandler do
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

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
end
