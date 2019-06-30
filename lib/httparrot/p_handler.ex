defmodule HTTParrot.PHandler do
  @moduledoc """
  This REST handler will respond to POST, PATCH and PUT requests.
  """
  alias HTTParrot.GeneralRequestInfo

  def init(req, state) do
    {:cowboy_rest, req, state}
  end

  @doc """
  When a request is made to /post, allowed_methods will return POST for example
  """
  def allowed_methods(req, state) do
    path = :cowboy_req.path(req)
    path = String.slice(path, 1..-1)
    {[String.upcase(path)], req, state}
  end

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
    {[{{"application", "json", []}, :undefined}], req, state}
  end

  def post_form(req, _state) do
    {:ok, body, req} = :cowboy_req.read_urlencoded_body(req)
    post(req, form: body, data: "", json: nil)
  end

  def post_binary(req, _state) do
    {:ok, body, req} = handle_binary(req)

    if String.valid?(body) do
      if JSX.is_json?(body) do
        post(req, form: [{}], data: body, json: JSX.decode!(body))
      else
        post(req, form: [{}], data: body, json: nil)
      end
    else
      # Octet-stream
      body = Base.encode64(body)
      post(req, form: [{}], data: "data:application/octet-stream;base64," <> body, json: nil)
    end
  end

  def handle_binary(req, chunks \\ []) do
    case :cowboy_req.read_body(req) do
      {:ok, chunk, req} ->
        {:ok, Enum.join(chunks ++ [chunk]), req}

      {:more, chunk, req} ->
        handle_binary(req, chunks ++ [chunk])
    end
  end

  defp post(req, body) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    req = :cowboy_req.set_resp_body(response(info, body), req)
    {true, req, nil}
  end

  defp response(info, body) do
    (info ++ body) |> JSX.encode!()
  end

  def post_multipart(req, _state) do
    {:ok, parts, req} = handle_multipart(req)

    file_parts = for file <- parts, elem(file, 0) == :file, do: {elem(file, 1), elem(file, 2)}
    form_parts = for form <- parts, elem(form, 0) == :form, do: {elem(form, 1), elem(form, 2)}

    post(req,
      form: normalize_list(form_parts),
      files: normalize_list(file_parts),
      data: "",
      json: nil
    )
  end

  def handle_multipart(req, parts \\ []) do
    case :cowboy_req.read_part(req) do
      {:done, req} ->
        {:ok, parts, req}

      {:ok, headers, req} ->
        content_disposition = headers["content-disposition"]

        if content_disposition do
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
    case :cowboy_req.read_part_body(req) do
      {:ok, data, req} ->
        {:ok, Enum.join(parts ++ [data]), req}

      {:more, data, req} ->
        handle_multipart_body(req, parts ++ [data])
    end
  end

  defp parse_content_disposition_header(header) do
    parts =
      String.split(header, ";")
      |> Enum.map(&String.trim/1)

    for part <- parts, into: %{} do
      case String.split(part, "=") |> Enum.map(&String.trim/1) do
        [type] -> {:type, type}
        [key, value] -> {key, String.replace(value, "\"", "")}
      end
    end
  end

  def normalize_list([]), do: [{}]

  def normalize_list(list), do: list
end
