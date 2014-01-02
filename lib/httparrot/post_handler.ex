defmodule HTTParrot.PostHandler do
  alias HTTParrot.GeneralRequestInfo

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["POST"], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :post_json},
      {{"application", "x-www-form-urlencoded", :*}, :post_form}], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :undefined}], req, state}
  end

  def post_form(req, _state) do
    {:ok, body, req} = :cowboy_req.body_qs(req)
    post(req, [form: body, data: "", json: nil])
  end

  def post_json(req, _state) do
    {:ok, body, req} = :cowboy_req.body(req)
    post(req, [form: [{}], data: body, json: JSEX.decode!(body)])
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
