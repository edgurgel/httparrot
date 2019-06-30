defmodule HTTParrot.Base64Handler do
  @moduledoc """
  Returns urlsafe base64 decoded data.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "octet-stream", []}, :get_binary}], req, state}
  end

  def malformed_request(req, state) do
    value = :cowboy_req.binding(:value, req)

    case decode(value) do
      {:ok, result} -> {false, req, result}
      :error -> {true, req, state}
    end
  end

  defp decode(value) do
    pad(value) |> Base.url_decode64()
  end

  defp pad(value) do
    case byte_size(value) |> rem(4) do
      2 -> value <> "=="
      3 -> value <> "="
      _ -> value
    end
  end

  def get_binary(req, result) do
    {result, req, result}
  end
end
