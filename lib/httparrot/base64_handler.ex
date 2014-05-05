defmodule HTTParrot.Base64Handler do
  @moduledoc """
  Returns urlsafe base64 decoded data.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {~W(GET HEAD OPTIONS), req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "octet-stream", []}, :get_binary}], req, state}
  end

  def malformed_request(req, state) do
    {value, req} = :cowboy_req.binding(:value, req)

    case decode(value) do
      { :ok, result } -> {false, req, result}
        :error -> {true, req, state}
    end
  end

  defp decode(value) do
    pad(value) |> Base.url_decode64
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

  def terminate(_, _, _), do: :ok
end
