defmodule UaiShotWeb.GameChannel do
  @moduledoc """
  Receive all the events of the game.
  """

  use Phoenix.Channel

  alias UaiShot.Store.{Player, Ranking, Food}


  def join("game:lobby", _message, socket) do
    {:ok, %{player_id: socket.assigns.player_id}, socket}
  end

  def join("game:" <> _private_game_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  @spec handle_in(<<_::64, _::_*8>>, any, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_in("new_player", state, socket) do
    state = format_state(state)
    nickname = socket.assigns.nickname
    player_id = socket.assigns.player_id

    state
    |> Map.put(:id, player_id)
    |> Map.put(:nickname, nickname)
    |> Player.put()

    Ranking.put(%{player_id: socket.assigns.player_id, nickname: nickname, value: 0})

    broadcast(socket, "update_players", %{players: Player.all()})
    broadcast(socket, "update_ranking", %{ranking: Ranking.all()})

    Food.put(%{player_id: 0, nickname: 0, value: 300,value2: 300})

    broadcast(socket, "update_food", %{players: Food.all()})

    {:noreply, socket}
  end


  def handle_in("player_rotate", state, socket) do
    state
    |> format_state
    |> Map.put(:id, socket.assigns.player_id)
    |> Map.put(:nickname, socket.assigns.nickname)
    |> Player.put()

    #broadcast(socket, "update_players", %{players: Player.all()})
    {:noreply, socket}
  end

  def terminate(_msg, socket) do
    player_id = socket.assigns.player_id
    Player.delete(player_id)
    Ranking.delete(player_id)

    broadcast(socket, "update_players", %{players: Player.all()})
    broadcast(socket, "update_ranking", %{ranking: Ranking.all()})
  end

  defp format_state(state) do
    for {key, val} <- state, into: %{}, do: {String.to_atom(key), val}
  end
end
