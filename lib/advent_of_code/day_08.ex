defmodule AdventOfCode.Day08.Grid do
  defstruct height: 0, width: 0, cells: []

  def new, do: %__MODULE__{}

  def add_line(line, %__MODULE__{height: height, width: width, cells: cells}) do
    cells = [line | cells]
    height = height + 1
    width = max(width, length(cells))
    %__MODULE__{height: height, width: width, cells: cells}
  end

  def finalize(%__MODULE__{cells: cells} = grid) do
    Map.put(grid, :cells, Enum.reverse(cells))
  end

  def get_cell_value(x, y, %__MODULE__{cells: cells}) do
    cells
    |> Enum.at(x)
    |> Enum.at(y)
  end

  def get_next_cell(dir, x, y) do
    case dir do
      :up -> {x + 1, y}
      :down -> {x - 1, y}
      :left -> {x, y - 1}
      :right -> {x, y + 1}
    end
  end

  def check_direction(_, _, _, _, nx, _) when nx < 0, do: true
  def check_direction(_, _, _, _, _, ny) when ny < 0, do: true
  def check_direction(_, _, _, %__MODULE__{height: height}, nx, _) when nx + 1 > height, do: true
  def check_direction(_, _, _, %__MODULE__{width: width}, _, ny) when ny + 1 > width, do: true

  def check_direction(dir, x, y, %__MODULE__{} = grid, nx, ny) do
    if get_cell_value(nx, ny, grid) >= get_cell_value(x, y, grid) do
      false
    else
      {nx, ny} = get_next_cell(dir, nx, ny)
      check_direction(dir, x, y, grid, nx, ny)
    end
  end

  def do_check_direction(dir, x, y, %__MODULE__{} = grid) do
    {nx, ny} = get_next_cell(dir, x, y)
    check_direction(dir, x, y, grid, nx, ny)
  end

  def is_visible(x, y, %__MODULE__{} = grid) do
    ~w(up down left right)a
    |> Enum.map(fn dir ->
      do_check_direction(dir, x, y, grid)
    end)
    |> Enum.any?()
  end

  def find_visible_trees(%__MODULE__{height: height, width: width} = grid) do
    for x <- 0..(height - 1) do
      for y <- 0..(width - 1) do
        is_visible(x, y, grid)
      end
    end
  end

  # def calc_scenic_dir(_, _, _, _, acc, nx, _) when nx < 0, do: acc
  # def calc_scenic_dir(_, _, _, _, acc, _, ny) when ny < 0, do: acc
  # def calc_scenic_dir(_, _, _, %__MODULE__{height: height}, acc, nx, _) when nx + 1 > height, do: acc
  # def calc_scenic_dir(_, _, _, %__MODULE__{width: width}, acc, _, ny) when ny + 1 > width, do: acc
  # def calc_scenic_dir(dir, x, y, %__MODULE__{} = grid, acc, nx, ny) do
  #
  #   if get_cell_value(nx, ny, grid) >= get_cell_value(x, y, grid) do
  #     acc
  #   else
  #     {nx, ny} = get_next_cell(dir, nx, ny)
  #     calc_scenic_dir(dir, x, y, grid, acc + 1, nx, ny)
  #   end
  # end
  #
  #
  #
  # def calc_scenic(x, y, %__MODULE__{} = grid) do
  #   ~w(up down left right)a
  #   |> Enum.map(fn dir ->
  #     {nx, ny} = get_next_cell(dir, x, y)
  #     calc_scenic_dir(dir, x, y, grid, 1, nx, ny)
  #   end)
  #   |> Enum.reduce(fn a, b -> a * b end)
  # end

  def create_direction_lists(x, y, %__MODULE__{height: height, width: width}) do
    left =
      0..x
      |> Enum.map(fn dx -> {dx, y} end)
      |> Enum.reject(fn point -> point == {x, y} end)

    right =
      x..(width - 1)
      |> Enum.map(fn dx -> {dx, y} end)
      |> Enum.reject(fn point -> point == {x, y} end)

    up =
      0..y
      |> Enum.map(fn dy -> {x, dy} end)
      |> Enum.reject(fn point -> point == {x, y} end)

    down =
      y..(height - 1)
      |> Enum.map(fn dy -> {x, dy} end)
      |> Enum.reject(fn point -> point == {x, y} end)

    [up, right, down, left]
  end

  def scenic_score(%__MODULE__{height: height, width: width} = grid) do
    for x <- 0..(width - 1) do
      for y <- 0..(height - 1) do
        this_value = get_cell_value(x, y, grid)

        create_direction_lists(x, y, grid)
        |> Enum.map(fn direction_list ->
          Enum.map(direction_list, fn {x, y} -> get_cell_value(x, y, grid) end)
          |> Enum.take_while(fn value -> value < this_value end)
        end)
        |> length
        |> Kernel.then(&(&1 + 1))
      end
    end
  end
end

defmodule AdventOfCode.Day08.GridMap do
  defstruct ~w(height width cells)a

  def new() do
    %__MODULE__{height: 0, width: 0, cells: Map.new()}
  end

  def add_line(line, %__MODULE__{height: height, width: width, cells: cells}) do
    cells =
      line
      |> Enum.with_index()
      |> Enum.reduce(cells, fn {val, index}, cells -> Map.put(cells, {index, height}, val) end)

    height = height + 1
    width = max(width, length(line))
    %__MODULE__{height: height, width: width, cells: cells}
  end

  def get_value({x, y}, %__MODULE__{cells: cells}) do
    Map.get(cells, {x, y})
  end

  def get_paths({x, y}, %__MODULE__{width: width, height: height, cells: cells}) do
    left =
      x..0
      |> Enum.map(fn nx -> {nx, y, Map.get(cells, {nx, y})} end)
      |> Enum.reject(fn {nx, ny, _} -> {nx, ny} == {x, y} end)
      |> Enum.map(fn {_, _, val} -> val end)

    right =
      x..(width - 1)
      |> Enum.map(fn nx -> {nx, y, Map.get(cells, {nx, y})} end)
      |> Enum.reject(fn {nx, ny, _} -> {nx, ny} == {x, y} end)
      |> Enum.map(fn {_, _, val} -> val end)

    up =
      y..0
      |> Enum.map(fn ny -> {x, ny, Map.get(cells, {x, ny})} end)
      |> Enum.reject(fn {nx, ny, _} -> {nx, ny} == {x, y} end)
      |> Enum.map(fn {_, _, val} -> val end)

    down =
      y..(height - 1)
      |> Enum.map(fn ny -> {x, ny, Map.get(cells, {x, ny})} end)
      |> Enum.reject(fn {nx, ny, _} -> {nx, ny} == {x, y} end)
      |> Enum.map(fn {_, _, val} -> val end)

    %{up: up, down: down, left: left, right: right}
  end

  def path_to_score(_, [], acc), do: acc
  def path_to_score(original_value, [head | tail], acc) do
    if original_value <= head do
      acc + 1
    else 
      path_to_score(original_value, tail, acc + 1)
    end
  end
end

defmodule AdventOfCode.Day08 do
  alias AdventOfCode.Day08.Grid
  alias AdventOfCode.Day08.GridMap

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn line ->
      Enum.map(line, fn char -> String.to_integer(char) end)
    end)
    |> Enum.reduce(Grid.new(), &Grid.add_line/2)
    |> Grid.find_visible_trees()
    |> Enum.concat()
    |> Enum.filter(& &1)
    |> length
  end

  def part2(args) do
    gridmap =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn line ->
        Enum.map(line, fn char -> String.to_integer(char) end)
      end)
      |> Enum.reduce(GridMap.new(), &GridMap.add_line/2)

    Map.get(gridmap, :cells) 
    |> Map.keys
    |> Enum.map(fn cell ->
        paths = Map.values(GridMap.get_paths(cell, gridmap))
        val = GridMap.get_value(cell, gridmap)

        paths
        |> Enum.map(& GridMap.path_to_score(val, &1, 0))
        |> Enum.reduce(fn a, b -> a * b end)
        end)
    |> Enum.max
  end
end
