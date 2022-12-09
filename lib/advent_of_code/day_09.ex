defmodule AdventOfCode.Day09.RopeGame do
  defstruct ~w(front back visited)a

  def new do
    %__MODULE__{front: {0, 0}, back: {0, 0}, visited: MapSet.new()}
  end

  def update_front(%__MODULE__{front: {x, y}} = game, dir) do
    front =
      case dir do
        "R" -> {x + 1, y}
        "U" -> {x, y + 1}
        "L" -> {x - 1, y}
        "D" -> {x, y - 1}
      end

    Map.put(game, :front, front)
  end

  def adjacent?({fx, fy}, {bx, by}) do
    abs(fx - bx) <= 1 and abs(fy - by) <= 1
  end

  def sync(:row, %__MODULE__{front: {fx, _}, back: {bx, by}} = game) do
    if fx > bx do
      Map.put(game, :back, {bx + 1, by})
    else
      Map.put(game, :back, {bx - 1, by})
    end
  end

  def sync(:col, %__MODULE__{front: {_, fy}, back: {bx, by}} = game) do
    if fy > by do
      Map.put(game, :back, {bx, by + 1})
    else
      Map.put(game, :back, {bx, by - 1})
    end
  end

  def sync(:diag, %__MODULE__{} = game) do
    sync(:row, game)
    |> Kernel.then(&sync(:col, &1))
  end

  def sync_back(%__MODULE__{front: {fx, fy} = front, back: {bx, by} = back} = game) do
    cond do
      adjacent?(front, back) -> game
      fx == bx -> sync(:col, game)
      fy == by -> sync(:row, game)
      true -> sync(:diag, game)
    end
  end

  def update_visited(%__MODULE__{back: back, visited: visited} = game) do
    Map.put(game, :visited, MapSet.put(visited, back))
  end

  def tick_game(%__MODULE__{} = game, [_, 0]), do: game

  def tick_game(%__MODULE__{} = game, [dir, amount]) do
    game
    |> update_front(dir)
    |> sync_back
    |> update_visited
    |> tick_game([dir, amount - 1])
  end

  def visited_amount(%__MODULE__{visited: visited}) do
    MapSet.size(visited)
  end
end

defmodule AdventOfCode.Day09.RopeGame2 do
  defstruct ~w(knots visited)a

  def new do
    knots =
      0..9
      |> Map.new(fn index -> {index, {0, 0}} end)

    %__MODULE__{knots: knots, visited: MapSet.new()}
  end

  def update_front(%__MODULE__{knots: knots} = game, dir) do
    {x, y} = Map.get(knots, 0)

    front =
      case dir do
        "R" -> {x + 1, y}
        "U" -> {x, y + 1}
        "L" -> {x - 1, y}
        "D" -> {x, y - 1}
      end

    Map.put(game, :knots, Map.put(knots, 0, front))
  end

  def adjacent?({fx, fy}, {bx, by}) do
    abs(fx - bx) <= 1 and abs(fy - by) <= 1
  end

  def sync(:row, index, %__MODULE__{knots: knots} = game) do
    {fx, _} = Map.get(knots, index)
    {bx, by} = Map.get(knots, index + 1)

    if fx > bx do
      Map.put(game, :knots, Map.put(knots, index + 1, {bx + 1, by}))
    else
      Map.put(game, :knots, Map.put(knots, index + 1, {bx - 1, by}))
    end
  end

  def sync(:col, index, %__MODULE__{knots: knots} = game) do
    {_, fy} = Map.get(knots, index)
    {bx, by} = Map.get(knots, index + 1)

    if fy > by do
      Map.put(game, :knots, Map.put(knots, index + 1, {bx, by + 1}))
    else
      Map.put(game, :knots, Map.put(knots, index + 1, {bx, by - 1}))
    end
  end

  def sync(:diag, index, %__MODULE__{} = game) do
    sync(:row, index, game)
    |> Kernel.then(&sync(:col, index, &1))
  end

  def sync_back(index, %__MODULE__{knots: knots} = game) do
    {fx, fy} = front = Map.get(knots, index)
    {bx, by} = back = Map.get(knots, index + 1)

    cond do
      adjacent?(front, back) -> game
      fx == bx -> sync(:col, index, game)
      fy == by -> sync(:row, index, game)
      true -> sync(:diag, index, game)
    end
  end

  def update_visited(%__MODULE__{knots: knots, visited: visited} = game) do
    back = Map.get(knots, 9)
    Map.put(game, :visited, MapSet.put(visited, back))
  end

  def tick_game(%__MODULE__{} = game, [_, 0]), do: game

  def tick_game(%__MODULE__{} = game, [dir, amount]) do
    game =
      game
      |> update_front(dir)

    0..8
    |> Enum.reduce(game, &sync_back/2)
    |> update_visited
    |> tick_game([dir, amount - 1])
  end

  def visited_amount(%__MODULE__{visited: visited}) do
    MapSet.size(visited)
  end
end

defmodule AdventOfCode.Day09 do
  alias AdventOfCode.Day09.RopeGame
  alias AdventOfCode.Day09.RopeGame2

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [dir, amount_str] -> [dir, String.to_integer(amount_str)] end)
    |> Enum.reduce(RopeGame.new(), &RopeGame.tick_game(&2, &1))
    |> Kernel.then(&RopeGame.visited_amount/1)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [dir, amount_str] -> [dir, String.to_integer(amount_str)] end)
    |> Enum.reduce(RopeGame2.new(), &RopeGame2.tick_game(&2, &1))
    |> Kernel.then(&RopeGame2.visited_amount/1)
  end
end
