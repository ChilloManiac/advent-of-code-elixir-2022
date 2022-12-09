defmodule AdventOfCode.Day08.Grid do
  defstruct height: 0, width: 0, cells: []

  def new, do: %__MODULE__{}

  def add_line(line, %__MODULE__{height: height, width: width, cells: cells}) do
    cells = [line | cells]
    height = height + 1
    width = max(width, length(cells))
    %__MODULE__{height: height, width: width, cells: cells}
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

  def calc_scenic_dir(_, _, _, _, acc, nx, _) when nx < 0, do: acc
  def calc_scenic_dir(_, _, _, _, acc, _, ny) when ny < 0, do: acc
  def calc_scenic_dir(_, _, _, %__MODULE__{height: height}, acc, nx, _) when nx + 1 > height, do: acc
  def calc_scenic_dir(_, _, _, %__MODULE__{width: width}, acc, _, ny) when ny + 1 > width, do: acc
  def calc_scenic_dir(dir, x, y, %__MODULE__{} = grid, acc, nx, ny) do

    if get_cell_value(nx, ny, grid) >= get_cell_value(x, y, grid) do
      acc
    else
      {nx, ny} = get_next_cell(dir, nx, ny)
      calc_scenic_dir(dir, x, y, grid, acc + 1, nx, ny)
    end
  end

  def calc_scenic(x, y, %__MODULE__{} = grid) do
    ~w(up down left right)a
    |> Enum.map(fn dir ->
      {nx, ny} = get_next_cell(dir, x, y)
      calc_scenic_dir(dir, x, y, grid, 1, nx, ny)
    end)
    |> Enum.reduce(fn a, b -> a * b end)
  end

  def scenic_score(%__MODULE__{height: height, width: width} = grid) do
    for x <- 0..(height - 1) do
      for y <- 0..(width - 1) do
        calc_scenic(x, y, grid)
      end
    end
  end
end

defmodule AdventOfCode.Day08 do
  alias AdventOfCode.Day08.Grid

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn line ->
      Enum.map(line, fn char -> String.to_integer(char) end)
    end)
    |> Enum.reduce(Grid.new(), &Grid.add_line/2)
    |> Grid.find_visible_trees()
    |> Enum.concat
    |> Enum.filter(& &1)
    |> length

    
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn line ->
      Enum.map(line, fn char -> String.to_integer(char) end)
    end)
    |> Enum.reduce(Grid.new(), &Grid.add_line/2)
    |> Grid.scenic_score
    |> dbg
  end
end
