defmodule AdventOfCode.Day12.HeightMap do
  defstruct ~w(heightmap height width start finish)a

  def new do
    %__MODULE__{heightmap: Map.new(), height: 0, width: 0, start: nil, finish: nil}
  end

  def add_line(
        line,
        %__MODULE__{
          heightmap: heightmap,
          height: height,
          width: width,
          start: start,
          finish: finish
        } = hm
      ) do
    line = line |> String.to_charlist()

    start =
      line
      |> Enum.with_index()
      |> Enum.filter(fn {elem, _} -> elem == ?S end)
      |> Kernel.then(fn
        [] -> start
        [{_, index} | _] -> {index, height}
      end)

    finish =
      line
      |> Enum.with_index()
      |> Enum.filter(fn {elem, _} -> elem == ?E end)
      |> Kernel.then(fn
        [] -> finish
        [{_, index} | _] -> {index, height}
      end)

    heightmap =
      line
      |> Enum.map(fn char ->
        case char do
          ?S -> ?a
          ?E -> ?z
          other -> other
        end
      end)
      |> Enum.with_index()
      |> Enum.reduce(heightmap, fn {value, index}, heightmap ->
        Map.put(heightmap, {index, height}, value)
      end)

    height = height + 1
    width = max(width, length(line))

    hm
    |> Map.put(:height, height)
    |> Map.put(:width, width)
    |> Map.put(:heightmap, heightmap)
    |> Map.put(:start, start)
    |> Map.put(:finish, finish)
  end

  def neighbours({x, y}, %__MODULE__{heightmap: heightmap}) do
    for point <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}] do
      if Map.has_key?(heightmap, point) do
        point
      else
        nil
      end
    end
    |> Enum.reject(&(&1 == nil))
  end

  def step([], _, visited), do: visited

  def step([next | tail], %__MODULE__{heightmap: heightmap} = hm, visited) do
    nb = neighbours(next, hm)
    this_val = Map.get(heightmap, next)
    this_path_length = Map.get(visited, next)

    traversable_nb =
      nb
      |> Enum.filter(fn nb ->
        nb_val = Map.get(heightmap, nb)
        nb_val - this_val <= 1
      end)
      |> Enum.reject(fn nb -> Map.has_key?(visited, nb) end)

    visited =
      traversable_nb
      |> Enum.reduce(visited, fn nb, visited -> Map.put(visited, nb, this_path_length + 1) end)

    step(tail ++ traversable_nb, hm, visited)
  end

  def shortest_path_between(%__MODULE__{finish: finish} = hm, start) do
    visited = step([start], hm, %{start => 0})
    Map.get(visited, finish)
  end

  def shortest_path_between(%__MODULE__{start: start, finish: finish} = hm) do
    visited = step([start], hm, %{start => 0})
    Map.get(visited, finish)
  end
end

defmodule AdventOfCode.Day12 do
  alias AdventOfCode.Day12.HeightMap

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.reduce(HeightMap.new(), &HeightMap.add_line/2)
    |> Kernel.then(&HeightMap.shortest_path_between/1)
  end

  def part2(args) do
    %{heightmap: heightmap} = hm =
      args
      |> String.split("\n", trim: true)
      |> Enum.reverse()
      |> Enum.reduce(HeightMap.new(), &HeightMap.add_line/2)

    heightmap
    |> Map.keys()
    |> Enum.filter(fn key -> Map.get(heightmap, key) == ?a end)
    |> Enum.map(fn start -> HeightMap.shortest_path_between(hm, start) end)
    |> Enum.sort(:asc)
  end
end
