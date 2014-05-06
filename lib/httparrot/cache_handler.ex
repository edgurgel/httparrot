defmodule HTTParrot.CacheHandler do
  @moduledoc """
  Returns 200 unless an If-Modified-Since or If-None-Match header is provided, when it returns a 304.
  """
  alias HTTParrot.GeneralRequestInfo

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {~W(GET HEAD OPTIONS), req, state}
  end

  def last_modified(req, state) do
    {{{2012, 9, 21}, {22, 36, 14}}, req, state}
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
