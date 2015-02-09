defmodule HTTParrot.GetHandler do
  @moduledoc """
  Returns GET data.
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    {response(info), req, state}
  end

  defp response(info) do
    info |> JSX.encode!
  end
end
