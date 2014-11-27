defmodule HTTParrot do
  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [ {'/', :cowboy_static, {:priv_file, :httparrot, "index.html"}},
             {'/ip', HTTParrot.IPHandler, []},
             {'/user-agent', HTTParrot.UserAgentHandler, []},
             {'/headers', HTTParrot.HeadersHandler, []},
             {'/get', HTTParrot.GetHandler, []},
             {'/post', HTTParrot.PHandler, []},
             {'/put', HTTParrot.PHandler, []},
             {'/patch', HTTParrot.PHandler, []},
             {'/delete', HTTParrot.DeleteHandler, []},
             {'/gzip', HTTParrot.GzipHandler, []},
             {'/status/:code', [code: :int], HTTParrot.StatusCodeHandler, []},
             {'/redirect/:n', HTTParrot.RedirectHandler, []},
             {'/redirect-to', HTTParrot.RedirectToHandler, []},
             {'/relative-redirect/:n', HTTParrot.RelativeRedirectHandler, []},
             {'/cookies', HTTParrot.CookiesHandler, []},
             {'/cookies/set[/:name/:value]', HTTParrot.SetCookiesHandler, []},
             {'/cookies/delete', HTTParrot.DeleteCookiesHandler, []},
             {'/basic-auth/:user/:passwd', HTTParrot.BasicAuthHandler, []},
             {'/hidden-basic-auth/:user/:passwd', HTTParrot.HiddenBasicAuthHandler, []},
             {'/stream/:n', HTTParrot.StreamHandler, []},
             {'/delay/:n', HTTParrot.DelayedHandler, []},
             {'/html', :cowboy_static, {:priv_file, :httparrot, "html.html"}},
             {'/deny', HTTParrot.DenyHandler, []},
             {'/cache', HTTParrot.CacheHandler, []},
             {'/robots.txt', HTTParrot.RobotsHandler, []},
             {'/base64/:value', HTTParrot.Base64Handler, []},
             {'/image', HTTParrot.ImageHandler, []},
             {'/websocket', HTTParrot.WebsocketHandler, []} ] }
    ])

    {:ok, http_port} = Application.fetch_env(:httparrot, :http_port)
    IO.puts "Starting HTTParrot on port #{http_port}"
    {:ok, _} = :cowboy.start_http(:http, 100,
      [port: http_port],
      [env: [dispatch: dispatch],
      onresponse: &prettify_json/4])

    if Application.get_env(:httparrot, :ssl, false) do
      {:ok, https_port} = Application.fetch_env(:httparrot, :https_port)
      priv_dir = :code.priv_dir(:httparrot)
      IO.puts "Starting HTTParrot on port #{https_port} (SSL)"
      {:ok, _} = :cowboy.start_https(:https, 100,
        [port: https_port, cacertfile: priv_dir ++ '/ssl/server-ca.crt',
         certfile: priv_dir ++ '/ssl/server.crt', keyfile: priv_dir ++ '/ssl/server.key'],
        [env: [dispatch: dispatch], onresponse: &prettify_json/4])
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def stop(_State), do: :ok

  def prettify_json(status, headers, body, req) do
    if JSEX.is_json? body do
      body = JSEX.prettify!(body)
      headers = List.keystore(headers, "content-length", 0, {"content-length", Integer.to_char_list(String.length(body))})
      {:ok, req} = :cowboy_req.reply(status, headers, body, req)
    end
    req
  end
end
