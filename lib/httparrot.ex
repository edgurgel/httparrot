defmodule HTTParrot do
  use Application.Behaviour

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
             {'/status/:code', HTTParrot.StatusCodeHandler, []},
             {'/redirect/:n', HTTParrot.RedirectHandler, []},
             {'/redirect-to', HTTParrot.RedirectToHandler, []},
             {'/cookies', HTTParrot.CookiesHandler, []},
             {'/cookies/set', HTTParrot.SetCookiesHandler, []},
             {'/cookies/delete', HTTParrot.DeleteCookiesHandler, []},
             {'/basic-auth/:user/:passwd', HTTParrot.BasicAuthHandler, []},
             {'/hidden-basic-auth/:user/:passwd', HTTParrot.HiddenBasicAuthHandler, []},
             {'/stream/:n', HTTParrot.StreamHandler, []},
             {'/delay/:n', HTTParrot.DelayedHandler, []},
             {'/html', :cowboy_static, {:priv_file, :httparrot, "html.html"}},
             {'/deny', HTTParrot.DenyHandler, []},
             {'/robots.txt', HTTParrot.RobotsHandler, []},
             {'/base64/:value', HTTParrot.Base64Handler, []},
             {'/websocket', HTTParrot.WebsocketHandler, []} ] }
    ])
    {:ok, http_port} = :application.get_env(:httparrot, :http_port)
    ssl = :application.get_env(:httparrot, :ssl, false)
    {:ok, _} = :cowboy.start_http(:http, 100, [port: http_port],
                                  [env: [dispatch: dispatch], onresponse: &prettify_json/4])

    if ssl do
      {:ok, https_port} = :application.get_env(:httparrot, :https_port)
      priv_dir = :code.priv_dir(:httparrot)
      {:ok, _} = :cowboy.start_https(:https, 100,
        [port: https_port, cacertfile: priv_dir ++ '/ssl/server-ca.crt',
         certfile: priv_dir ++ '/ssl/server.crt', keyfile: priv_dir ++ '/ssl/server.key'],
        [env: [dispatch: dispatch], onresponse: &prettify_json/4])
        IO.puts "Starting HTTParrot on port #{https_port} (SSL)"
    end
    IO.puts "Starting HTTParrot on port #{http_port}"
    HTTParrot.Supervisor.start_link
  end

  def stop(_State), do: :ok

  def prettify_json(status, headers, body, req) do
    if JSEX.is_json? body do
      body = JSEX.prettify!(body)
      headers = ListDict.put(headers, "content-length", integer_to_list(String.length(body)))
      {:ok, req} = :cowboy_req.reply(status, headers, body, req)
    end
    req
  end
end
