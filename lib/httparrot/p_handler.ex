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
      {{"application", "x-www-form-urlencoded", :*}, :post_form},
      {{"multipart", "form-data", :*}, :post_multipart}], req, state}
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
      body = Base.encode64(body)
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

  def post_multipart(req, _state) do
    {:ok, parts, req} = handle_multipart(req)

    filter = fn({type, _name, _body}, type_atom) -> type == type_atom end
    reducer = fn({_type, name, body}, acc) -> acc ++ [{name, body}] end

    # the other post handlers return a list with a single empty tuple if
    # there's no data for forms, so let's match that behavior...
    normalize = fn(parts) -> if parts == [], do: [{}], else: parts end

    file_parts = Enum.filter(parts, &(filter.(&1, :file)))
      |> Enum.reduce([], &(reducer.(&1, &2)))
      |> normalize.()

    form_parts = Enum.filter(parts, &(filter.(&1, :form)))
      |> Enum.reduce([], &(reducer.(&1, &2)))
      |> normalize.()

    post(req, [form: form_parts, files: file_parts, data: "", json: nil])
  end

  defp handle_multipart(req, parts \\ []) do
    case :cowboy_req.part(req) do
      {:done, req} -> {:ok, parts, req}
      {:ok, headers, req} ->
        content_disposition = List.keyfind(headers, "content-disposition", 0)
        if content_disposition != nil do
          case parse_content_disposition_header(content_disposition) do
            %{:type => "form-data", "name" => name, "filename" => _filename} ->
              {:ok, file, req} = handle_multipart_body(req)
              handle_multipart(req, parts ++ [{:file, name, file}])
            %{:type => "form-data", "name" => name} ->
              {:ok, form_part, req} = handle_multipart_body(req)
              handle_multipart(req, parts ++ [{:form, name, form_part}])
            _ ->
              {:ok, parts, req}
          end
        else
          {:ok, parts, req}
        end
    end
  end

  defp handle_multipart_body(req, parts \\ []) do
    case :cowboy_req.part_body(req) do
      {:ok, data, req} ->
        {:ok, Enum.join(parts ++ [data]), req}
      {:more, data, req} ->
        handle_multipart_body(req, parts ++ [data])
    end
  end

  defp parse_content_disposition_header(header) do
    parts = elem(header, 1) |> String.split(";")

    type = Enum.at(parts, 0)
    parts = Enum.drop(parts, 1)

    Enum.reduce(parts, %{:type => type}, fn part, acc ->
      [key, value] = String.split(part, "=")
      key = String.strip(key)
      value = String.strip(value) |> String.replace("\"", "")
      Map.put(acc, key, value)
    end)
  end
end
