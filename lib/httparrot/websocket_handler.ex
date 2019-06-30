defmodule HTTParrot.WebsocketHandler do
  @behaviour :cowboy_websocket
  @moduledoc """
  Echo given messages through websocket connection
  """

  def init(req, state), do: {:cowboy_websocket, req, state}
  def websocket_init(state), do: {:ok, state}

  def websocket_handle({:text, text}, state), do: {:reply, {:text, text}, state}
  def websocket_handle({:binary, binary}, state), do: {:reply, {:binary, binary}, state}

  def websocket_info(_info, state), do: {:ok, state}

  def terminate(_reason, _req, _state), do: :ok
end
