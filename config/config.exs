import Mix.Config

port = System.get_env("PORT", "8080")
port = String.to_integer(port)

ssl_port = System.get_env("SSL_PORT", "8433")
ssl_port = String.to_integer(ssl_port)

unix_socket = System.get_env("UNIX_SOCKET", "false")
unix_socket = if unix_socket == "true", do: true, else: false

config :httparrot,
  http_port: port,
  https_port: ssl_port,
  unix_socket: unix_socket,
  socket_path: System.get_env("SOCKET_PATH", "httparrot.sock")

