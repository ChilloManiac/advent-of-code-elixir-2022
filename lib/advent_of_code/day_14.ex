defmodule AdventOfCode.Day14.Container do
  defstruct ~w(grid depth )a

  def new do
    %__MODULE__{grid: Map.new(), depth: 0}
  end

  def add_rocks(%__MODULE__{} = container, list) when length(list) <= 1, do: container

  def add_rocks(%__MODULE__{grid: grid} = container, [{from_x, from_y}, {to_x, to_y} | tail]) do
    grid =
      for x <- from_x..to_x,
          y <- from_y..to_y do
        {x, y}
      end
      |> Enum.reduce(grid, fn coord, grid -> Map.put(grid, coord, :rock) end)

    container =
      container
      |> Map.put(:grid, grid)
      |> Map.update!(:depth, fn depth -> max(depth, max(from_y, to_y)) end)

    add_rocks(
      container,
      [{to_x, to_y} | tail]
    )
  end

  def put_line(line, %__MODULE__{} = container) do
    coords =
      line
      |> String.split(" -> ", trim: true)
      |> Enum.map(fn coord_str ->
        [x, y] = String.split(coord_str, ",")
        {String.to_integer(x), String.to_integer(y)}
      end)

    add_rocks(container, coords)
  end

  def occupied?(%__MODULE__{grid: grid}, x, y) do
    Map.has_key?(grid, {x, y})
  end

  def put_sand(container, coord \\ {500, 0})
  def put_sand(%__MODULE__{depth: depth}, {_, depth}), do: :void
  def put_sand(%__MODULE__{} = container, {x, y}) do
    case {occupied?(container, x - 1, y + 1), occupied?(container, x, y + 1),
          occupied?(container, x + 1, y + 1)} do
      {_, false, _} -> put_sand(container, {x, y + 1})
      {false, _, _} -> put_sand(container, {x - 1, y + 1})
      {_, _, false} -> put_sand(container, {x + 1, y + 1})
      _ -> Map.update!(container, :grid, fn grid -> Map.put(grid, {x, y}, :sand) end)
    end
  end

  def keep_putting_sand(%__MODULE__{} = container, acc) do
    case put_sand(container) do
      :void -> acc
      container -> keep_putting_sand(container, acc + 1)
    end
  end

  def put_sand2(container, coord \\ {500, 0})
  def put_sand2(%__MODULE__{depth: depth} = container, {x, y}) when y == depth + 1 do
      Map.update!(container, :grid, fn grid -> Map.put(grid, {x, y}, :sand) end)
  end 
  def put_sand2(%__MODULE__{} = container, {x, y}) do
    case {occupied?(container, x - 1, y + 1), occupied?(container, x, y + 1),
          occupied?(container, x + 1, y + 1)} do
      {_, false, _} -> put_sand2(container, {x, y + 1})
      {false, _, _} -> put_sand2(container, {x - 1, y + 1})
      {_, _, false} -> put_sand2(container, {x + 1, y + 1})
      _ when {x, y} == {500, 0} -> :full
      _ -> Map.update!(container, :grid, fn grid -> Map.put(grid, {x, y}, :sand) end)
    end
  end

  def keep_putting_sand2(%__MODULE__{} = container, acc) do
    case put_sand2(container) do
      :full -> acc
      container -> keep_putting_sand2(container, acc + 1)
    end
  end
end

defmodule AdventOfCode.Day14 do
  alias __MODULE__.Container

  def part1(args) do
    container =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Container.new(), &Container.put_line/2)


    Container.keep_putting_sand(container, 0)
  end

  def part2(args) do
    container =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Container.new(), &Container.put_line/2)


    Container.keep_putting_sand2(container, 1)
  end
end
