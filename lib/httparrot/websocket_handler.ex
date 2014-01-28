defmodule HTTParrot.WebsocketHandler do
  @behaviour :cowboy_websocket_handler
  @moduledoc """
  Echo given messages through websocket connection
  """

  def init(_transport, _req, _opts), do: {:upgrade, :protocol, :cowboy_websocket}
  def websocket_init(_transport, req, _opts), do: {:ok, req, nil}

  def websocket_handle({:text, text}, req, state), do: {:reply, {:text, text}, req, state}
  def websocket_handle({:binary, binary}, req, state), do: {:reply, {:binary, binary}, req, state}
  def websocket_info(_info, req, state), do: {:ok, req, state}

  def websocket_terminate(_reason, _req, _state), do: :ok
end
