defmodule HTTParrot.PHandlerTest do
  use ExUnit.Case
  import :meck
  import HTTParrot.PHandler

  setup do
    new HTTParrot.GeneralRequestInfo
    new JSEX
    new :cowboy_req
    on_exit fn -> unload end
    :ok
  end

  Enum.each [{"/post", "POST"},
             {"/patch", "PATCH"},
             {"/put", "PUT"}], fn {path, verb} ->
    test "allowed_methods return verb related to #{path}" do
      expect(:cowboy_req, :path, 1, {unquote(path), :req2})

      assert allowed_methods(:req1, :state) == {[unquote(verb)], :req2, :state}

      assert validate :cowboy_req
    end
  end

  test "returns json with general info and P[OST, ATCH, UT] form data" do
    expect(:cowboy_req, :body_qs, 1, {:ok, :body_qs, :req2})
    expect(:cowboy_req, :set_resp_body, [{[:response, :req3], :req4}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req3})
    expect(JSEX, :encode!, [{[[:info, {:form, :body_qs}, {:data, ""}, {:json, nil}]], :response}])

    assert post_form(:req1, :state) == {true, :req4, nil}

    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, ATCH, UT] JSON body data" do
    expect(:cowboy_req, :body, 1, {:ok, "body", :req2})
    expect(:cowboy_req, :set_resp_body, [{[:response, :req3], :req4}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req3})
    expect(JSEX, :is_json?, 1, true)
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(JSEX, :encode!, [{[[:info, {:form, [{}]}, {:data, "body"}, {:json, :decoded_json}]], :response}])

    assert post_binary(:req1, :state) == {true, :req4, nil}

    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, ATCH, UT] non-JSON body data" do
    expect(:cowboy_req, :body, 1, {:ok, "body", :req2})
    expect(:cowboy_req, :set_resp_body, [{[:response, :req3], :req4}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req3})
    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{}]}, {:data, "body"}, {:json, nil}]], :response}])

    assert post_binary(:req1, :state) == {true, :req4, nil}

    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, ATCH, UT] octet-stream body data" do
    expect(:cowboy_req, :body, 1, {:ok, <<0xffff :: 16>>, :req2})
    expect(:cowboy_req, :set_resp_body, [{[:response, :req3], :req4}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req3})
    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{}]}, {:data, "data:application/octet-stream;base64,//8="}, {:json, nil}]], :response}])

    assert post_binary(:req1, :state) == {true, :req4, nil}

    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, ATCH, UT] octet-stream body data for multipart request (simple)" do
    expect(:cowboy_req, :part, fn req ->
      case req do
        :req1 ->
          {:ok, [{"content-disposition", "form-data; name=\"key1\""}], :req2}
        :req3 ->
          {:done, :req4}
      end
    end)

    expect(:cowboy_req, :part_body, [{[:req2], {:ok, "value1", :req3}}])
    expect(:cowboy_req, :parse_header,
      [{["content-type", :req4],
      {:ok, {"multipart", "form-data", [{"boundary", "----WebKitFormBoundary8BEQxJvZANFsvRV9"}]}, :req5}}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req6})

    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{"key1", "value1"}]}, {:files, [{}]}, {:data, ""}, {:json, nil}]], :response}])

    expect(:cowboy_req, :set_resp_body, [{[:response, :req6], :req7}])

    assert post_multipart(:req1, :state) == {true, :req7, nil}
    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, ATCH, UT] octet-stream body data for multipart requests (multiple parts)" do
    expect(:cowboy_req, :part, fn req ->
      case req do
        :req1 ->
          {:ok, [{"content-disposition", "form-data; name=\"key1\""}], :req2}
        :req3 ->
          {:ok, [{"content-disposition", "form-data; name=\"key2\""}], :req4}
        :req5 ->
          {:done, :req6}
      end
    end)

    expect(:cowboy_req, :part_body, fn req ->
      case req do
        :req2 -> {:ok, "value1", :req3}
        :req4 -> {:ok, "value2", :req5}
      end
    end)

    expect(:cowboy_req, :parse_header,
      [{["content-type", :req6],
      {:ok, {"multipart", "form-data", [{"boundary", "----WebKitFormBoundary8BEQxJvZANFsvRV9"}]}, :req7}}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req8})

    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{"key1", "value1"}, {"key2", "value2"}]}, {:files, [{}]}, {:data, ""}, {:json, nil}]], :response}])

    expect(:cowboy_req, :set_resp_body, [{[:response, :req8], :req9}])

    assert post_multipart(:req1, :state) == {true, :req9, nil}
    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, UT, ATCH] file data (one file)" do
    expect(:cowboy_req, :part, fn req ->
      case req do
        :req1 ->
          {:ok, [{"content-disposition", "form-data; name=\"file1\"; filename=\"testdata.txt\""}, {"content-type", "text/plain"}], :req2}
        :req3 ->
          {:done, :req4}
      end
    end)

    expect(:cowboy_req, :part_body, [{[:req2], {:ok, "here is some cool\ntest data.", :req3}}])
    expect(:cowboy_req, :parse_header,
      [{["content-type", :req4],
      {:ok, {"multipart", "form-data", [{"boundary", "----WebKitFormBoundary8BEQxJvZANFsvRV9"}]}, :req5}}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req6})

    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{}]}, {:files, [{"file1", "here is some cool\ntest data."}]}, {:data, ""}, {:json, nil}]], :response}])

    expect(:cowboy_req, :set_resp_body, [{[:response, :req6], :req7}])

    assert post_multipart(:req1, :state) == {true, :req7, nil}
    assert validate HTTParrot.GeneralRequestInfo
  end

  test "returns json with general info and P[OST, UT, ATCH] file data (form-data plus one file)" do
    expect(:cowboy_req, :part, fn req ->
      case req do
        :req1 ->
          {:ok, [{"content-disposition", "form-data; name=\"key1\""}], :req2}
        :req3 ->
          {:ok, [{"content-disposition", "form-data; name=\"file1\"; filename=\"testdata.txt\""}, {"content-type", "text/plain"}], :req4}
        :req5 ->
          {:done, :req6}
      end
    end)

    expect(:cowboy_req, :part_body, fn req ->
      case req do
        :req2 -> {:ok, "value1", :req3}
        :req4 -> {:ok, "here is some cool\ntest data", :req5}
      end
    end)

    expect(:cowboy_req, :parse_header,
      [{["content-type", :req6],
      {:ok, {"multipart", "form-data", [{"boundary", "----WebKitFormBoundary8BEQxJvZANFsvRV9"}]}, :req7}}])
    expect(HTTParrot.GeneralRequestInfo, :retrieve, 1, {[:info], :req8})

    expect(JSEX, :is_json?, 1, false)
    expect(JSEX, :encode!, [{[[:info, {:form, [{"key1", "value1"}]}, {:files, [{"file1", "here is some cool\ntest data"}]}, {:data, ""}, {:json, nil}]], :response}])

    expect(:cowboy_req, :set_resp_body, [{[:response, :req8], :req9}])

    assert post_multipart(:req1, :state) == {true, :req9, nil}
    assert validate HTTParrot.GeneralRequestInfo
  end
end
