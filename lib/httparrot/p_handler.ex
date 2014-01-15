defmodule HTTParrot.PHandler do
  @moduledoc """
  This REST handler will respond to POST, PATCH and PUT requests.
  """
  alias HTTParrot.GeneralRequestInfo

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  @doc """
  When a request is made to /post, allowed_methods will return POST for example
  """
  def allowed_methods(req, state) do
    {path, req} = :cowboy_req.path(req)
    path = String.slice(path, 1..-1)
    {[String.upcase(path)], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :post_binary},
      {{"application", "octet-stream", :*}, :post_binary},
      {{"text", "plain", :*}, :post_binary},
      {{"application", "x-www-form-urlencoded", :*}, :post_form}], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :undefined}], req, state}
  end

  def post_form(req, _state) do
    {:ok, body, req} = :cowboy_req.body_qs(req)
    post(req, [form: body, data: "", json: nil])
  end

  def post_binary(req, _state) do
    {:ok, body, req} = :cowboy_req.body(req)
    if String.valid?(body) do
      if JSEX.is_json?(body) do
        post(req, [form: [{}], data: body, json: JSEX.decode!(body)])
      else
        post(req, [form: [{}], data: body, json: nil])
      end
    else
      # Octet-stream
      body = :base64.encode(body)
      post(req, [form: [{}], data: "data:application/octet-stream;base64," <> body, json: nil])
    end
  end

  defp post(req, body) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    req = :cowboy_req.set_resp_body(response(info, body), req)
    {true, req, nil}
  end

  defp response(info, body) do
    info ++ body |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
