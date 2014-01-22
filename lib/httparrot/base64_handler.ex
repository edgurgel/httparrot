defmodule HTTParrot.Base64Handler do
  @moduledoc """
  Returns urlsafe base64 decoded data.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "octet-stream", []}, :get_binary}], req, state}
  end

  def get_binary(req, state) do
    {value, req} = :cowboy_req.binding(:value, req)
    value = decode(value)
    {value, req, state}
  end

  defp decode(bin) when is_binary(bin) do
    bin = case rem(byte_size(bin), 4) do
      2 -> << bin :: binary, "==" >>
      3 -> << bin :: binary, "=" >>
      _ -> bin
    end
    bc <<x>> inbits :base64.decode(bin), x != ?=, do: <<urldecode_digit(x)>>
  end

  defp urldecode_digit(?_), do: ?/
  defp urldecode_digit(?-), do: ?+
  defp urldecode_digit(d), do: d

  def terminate(_, _, _), do: :ok
end
