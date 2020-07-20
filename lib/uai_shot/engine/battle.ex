defmodule UaiShot.Engine.Battle do
  @moduledoc """
  Game battle logic.
  """

  alias UaiShot.Store.{Player, Ranking, Food}

  alias UaiShotWeb.Endpoint

  @game_width 600
  @game_height 600

  @doc """
  Run game battle logic.
  """
  def run do

    #判断是否吃到食物
    Food.all()
    |> Enum.map(&judge_food(&1))

    Endpoint.broadcast("game:lobby",  "update_food", %{food: Food.all()})

    #判断撞墙
    judge_bound()
    |>Enum.each(&process_bound_hit(&1))

    #Run玩家移动
    move_player()

    Endpoint.broadcast("game:lobby",  "update_players", %{players: Player.all()})
  end
#///////////////////////////////////////////////
#这里这里
  defp move_player() do
    Player.all()
      |> Enum.each(&process_move(&1))
  end

  defp process_move(player) do
    thisPlayer =
      player.id
      |> Player.get()

    thisPlayer
    |> Map.update!(:x, &(&1 + Map.get(thisPlayer, :deltaX)))
    |> Map.update!(:y, &(&1 + Map.get(thisPlayer, :deltaY)))
    |> Player.put()

    pos_x = Map.get(thisPlayer, :x)
    pos_y = Map.get(thisPlayer, :y)

    if pos_y < 0 do
      player.id |> Player.get()|> Map.put(:y, @game_height)|> Player.put()
    end
    if pos_y > @game_height do
      player.id |> Player.get() |> Map.put(:y, 0) |> Player.put()
    end
    if pos_x < 0 do
      player.id |> Player.get() |> Map.put(:x, @game_width) |> Player.put()
    end
    if pos_x > @game_width do
      player.id |> Player.get() |> Map.put(:x, 0) |> Player.put()
    end

    #Endpoint.broadcast("game:lobby",  "against_player", %{player_id: player.id })
  end

#///////////////////////////////////////////////
  defp process_bound_hit(player) do
    Endpoint.broadcast("game:lobby",  "against_player", %{player_id: player.id })
  end

  defp judge_bound() do
    Player.all()
    |> Enum.filter(fn player ->
      player.x < -10 || player.x > @game_width || player.y < -10 || player.y > @game_height
    end)
  end

#///////////////////////////////////////////////
  defp judge_food(food) do
    food
    |> hited_players
    |> Enum.each(&process_hit(&1))
  end

  defp hited_players(food) do
    Player.all()
    |> Enum.filter(fn player ->
      dx = player.x - food.value
      dy = player.y - food.value2
      :math.sqrt(dx * dx + dy * dy) < 30
    end)
  end

  defp process_hit(player) do
    update_ranking(player.id, 10)

    Endpoint.broadcast("game:lobby", "update_ranking", %{ranking: Ranking.all()})
    update_food()
  end


  defp update_food()do
    0
    |> Food.get()
    |> Map.update!(:value, &(&1 = Enum.random(1..@game_width)))
    |> Map.update!(:value2, &(&1 = Enum.random(1..@game_height)))
    |> Food.put()
  end

  defp update_ranking(player_id, value) do
    player_id
    |> Ranking.get()
    |> Map.update!(:value, &(&1 + value))
    |> Ranking.put()
  end
#///////////////////////////////////////////////



end
