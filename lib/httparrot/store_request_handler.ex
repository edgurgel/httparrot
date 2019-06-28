defmodule HTTParrot.StoreRequestHandler do
  @moduledoc """
  Store the sended request with the :id
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET POST PUT HEAD OPTIONS)

  def content_types_accepted(req, state) do
    {[
       {{"application", "json", :*}, :post_binary},
       {{"application", "octet-stream", :*}, :post_binary},
       {{"text", "plain", :*}, :post_binary},
       {{"application", "x-www-form-urlencoded", :*}, :post_form},
       {{"multipart", "form-data", :*}, :post_multipart}
     ], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get}], req, state}
  end

  def get(req, state) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    {key, _} = :cowboy_req.binding(:key, req)
    HTTParrot.RequestStore.store(key, info)
    {'{"saved":  "true"}', req, state}
  end

  def post_binary(req, _state) do
    {:ok, body, req} = HTTParrot.PHandler.handle_binary(req)

    if String.valid?(body) do
      if JSX.is_json?(body) do
        save_post(req, form: [{}], data: body, json: JSX.decode!(body))
      else
        save_post(req, form: [{}], data: body, json: nil)
      end
    else
      # Octet-stream
      body = Base.encode64(body)
      save_post(req, form: [{}], data: "data:application/octet-stream;base64," <> body, json: nil)
    end
  end

  def post_form(req, _state) do
    {:ok, body, req} = :cowboy_req.read_urlencoded_body(req)
    save_post(req, form: body, data: "", json: nil)
  end

  def post_multipart(req, _state) do
    {:ok, parts, req} = HTTParrot.PHandler.handle_multipart(req)

    file_parts = for file <- parts, elem(file, 0) == :file, do: {elem(file, 1), elem(file, 2)}
    form_parts = for form <- parts, elem(form, 0) == :form, do: {elem(form, 1), elem(form, 2)}

    save_post(req,
      form: HTTParrot.PHandler.normalize_list(form_parts),
      files: HTTParrot.PHandler.normalize_list(file_parts),
      data: "",
      json: nil
    )
  end

  def save_post(req, body) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    key = :cowboy_req.binding(:key, req)
    HTTParrot.RequestStore.store(key, info ++ body)
    req = :cowboy_req.reply(200, %{}, '{"saved":  "true"}', req)
    {:halt, req, nil}
  end
end
