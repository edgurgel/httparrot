defmodule HTTParrot do
  use Application
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_) do
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def start(_type, _args) do
    dispatch =
      :cowboy_router.compile([
        {:_,
         [
           {"/", :cowboy_static, {:priv_file, :httparrot, "index.html"}},
           {"/ip", HTTParrot.IPHandler, []},
           {"/user-agent", HTTParrot.UserAgentHandler, []},
           {"/headers", HTTParrot.HeadersHandler, []},
           {"/get", HTTParrot.GetHandler, []},
           {"/post", HTTParrot.PHandler, []},
           {"/put", HTTParrot.PHandler, []},
           {"/patch", HTTParrot.PHandler, []},
           {"/delete", HTTParrot.DeleteHandler, []},
           {"/deflate", HTTParrot.DeflateHandler, []},
           {"/gzip", HTTParrot.GzipHandler, []},
           {"/status/:code", [code: :int], HTTParrot.StatusCodeHandler, []},
           {"/redirect/:n", HTTParrot.RedirectHandler, []},
           {"/redirect-to", HTTParrot.RedirectToHandler, []},
           {"/relative-redirect/:n", HTTParrot.RelativeRedirectHandler, []},
           {"/cookies", HTTParrot.CookiesHandler, []},
           {"/cookies/set[/:name/:value]", HTTParrot.SetCookiesHandler, []},
           {"/cookies/delete", HTTParrot.DeleteCookiesHandler, []},
           {"/basic-auth/:user/:passwd", HTTParrot.BasicAuthHandler, []},
           {"/hidden-basic-auth/:user/:passwd", HTTParrot.HiddenBasicAuthHandler, []},
           {"/stream/:n", HTTParrot.StreamHandler, []},
           {"/stream-bytes/:n", HTTParrot.StreamBytesHandler, []},
           {"/delay/:n", HTTParrot.DelayedHandler, []},
           {"/html", :cowboy_static, {:priv_file, :httparrot, "html.html"}},
           {"/deny", HTTParrot.DenyHandler, []},
           {"/cache", HTTParrot.CacheHandler, []},
           {"/robots.txt", HTTParrot.RobotsHandler, []},
           {"/base64/:value", HTTParrot.Base64Handler, []},
           {"/image", HTTParrot.ImageHandler, []},
           {"/websocket", HTTParrot.WebsocketHandler, []},
           {"/response-headers", HTTParrot.ResponseHeadersHandler, []},
           {"/store/:key", HTTParrot.StoreRequestHandler, []},
           {"/retrieve/:key", HTTParrot.RetrieveRequestHandler, []}
         ]}
      ])

    {:ok, http_port} = Application.fetch_env(:httparrot, :http_port)
    IO.puts("Starting HTTParrot on port #{http_port}")

    {:ok, _} =
      :cowboy.start_clear(
        :http,
        [port: http_port],
        %{env: %{dispatch: dispatch}}
      )

    if Application.get_env(:httparrot, :ssl, false) do
      {:ok, https_port} = Application.fetch_env(:httparrot, :https_port)
      priv_dir = :code.priv_dir(:httparrot)
      IO.puts("Starting HTTParrot on port #{https_port} (SSL)")

      {:ok, _} =
        :cowboy.start_tls(
          :https,
          [
            port: https_port,
            cacertfile: priv_dir ++ ~c"/ssl/server-ca.crt",
            certfile: priv_dir ++ ~c"/ssl/server.crt",
            keyfile: priv_dir ++ ~c"/ssl/server.key"
          ],
          %{env: %{dispatch: dispatch}}
        )
    end

    if unix_socket_supported?() && Application.get_env(:httparrot, :unix_socket, false) do
      {:ok, socket_path} = Application.fetch_env(:httparrot, :socket_path)
      if File.exists?(socket_path), do: File.rm(socket_path)
      IO.puts("Starting HTTParrot on unix socket #{socket_path}")

      {:ok, _} =
        :cowboy.start_clear(
          :http_unix,
          [port: 0, ip: {:local, socket_path}],
          %{env: %{dispatch: dispatch}}
        )
    end

    Supervisor.start_link(
      [
        {ConCache,
         [
           ttl_check_interval: :timer.minutes(5),
           global_ttl: :timer.hours(12),
           name: :requests_registry
         ]}
      ],
      strategy: :one_for_one
    )
  end

  def stop(_State), do: :ok

  def prettify_json(status, headers, body, req) do
    if JSX.is_json?(body) do
      body = JSX.prettify!(body)

      headers = Map.put(headers, "content-length", Integer.to_charlist(String.length(body)))

      :cowboy_req.reply(status, headers, body, req)
    else
      req
    end
  end

  def unix_socket_supported? do
    case {:os.type(), Integer.parse("#{:erlang.system_info(:otp_release)}")} do
      {{:unix, _}, {n, _}} when n >= 19 -> true
      _ -> false
    end
  end
end
