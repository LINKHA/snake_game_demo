defmodule UaiShot.Store.Food do

  use Agent
  alias UaiShot.Store.Player

  @doc """
  Start Store.
  """
  def start_link(state \\ %{}) do
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  @doc """
  Return ranking.
  """
  def all do
    Agent.get(__MODULE__, fn players ->
      players
      |> Map.to_list()
      |> Enum.map(&elem(&1, 1))
      #|> Enum.sort(&(&1.value > &2.value))
    end)
  end

  @doc """
  Update or insert a ranking position.
  """
  def put(position) do
    Agent.update(__MODULE__, &Map.put(&1, position.player_id, position))
  end

  @doc """
  Get ranking position by player_id.
  """
  def get(player_id) do
    Agent.get(__MODULE__, &Map.get(&1, player_id, default_attrs(player_id)))
  end

  @doc """
  Delete ranking position by player_id.
  """
  def delete(player_id) do
    Agent.update(__MODULE__, &Map.delete(&1, player_id))
  end

  @doc """
  Clean ranking positions.
  """
  def clean do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  def reset(foods) do
    Agent.update(__MODULE__, fn _ -> foods end)
  end

  defp default_attrs(player_id) do
    nickname = Player.get(player_id).nickname
    %{player_id: player_id, nickname: nickname, value: 0, value2: 0}
  end
end
