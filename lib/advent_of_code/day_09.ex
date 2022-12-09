defmodule AdventOfCode.Day09.RopeGame do
  defstruct ~w(knots visited last)a

  def new(length) do
    knots =
      0..length - 1
      |> Map.new(fn index -> {index, {0, 0}} end)

    %__MODULE__{knots: knots, visited: MapSet.new(), last: length - 1}
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

  def update_visited(%__MODULE__{knots: knots, visited: visited, last: last} = game) do
    back = Map.get(knots, last)
    Map.put(game, :visited, MapSet.put(visited, back))
  end

  def tick_game(%__MODULE__{} = game, [_, 0]), do: game

  def tick_game(%__MODULE__{last: last} = game, [dir, amount]) do
    game =
      game
      |> update_front(dir)

    0..(last - 1)
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

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [dir, amount_str] -> [dir, String.to_integer(amount_str)] end)
    |> Enum.reduce(RopeGame.new(2), &RopeGame.tick_game(&2, &1))
    |> Kernel.then(&RopeGame.visited_amount/1)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [dir, amount_str] -> [dir, String.to_integer(amount_str)] end)
    |> Enum.reduce(RopeGame.new(10), &RopeGame.tick_game(&2, &1))
    |> Kernel.then(&RopeGame.visited_amount/1)
  end
end
