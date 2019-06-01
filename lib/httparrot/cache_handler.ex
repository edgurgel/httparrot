defmodule HTTParrot.CacheHandler do
  @moduledoc """
  Returns 200 unless an If-Modified-Since or If-None-Match header is provided, when it returns a 304.
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

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
    info |> JSX.encode!()
  end
end
