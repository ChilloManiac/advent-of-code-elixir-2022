defmodule AdventOfCode.Day17.Tetris do
  defstruct ~w(grid highest_point)a

  @shapes [
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}],
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  ]

  def start_shape_agent do
    Agent.start_link(fn -> {0, @shapes} end)
  end

  def get_next(agent) do
    Agent.get_and_update(agent, fn {index, items} ->
      next_item = Enum.at(items, index)
      next_index = rem(index + 1, length(items))
      {next_item, {next_index, items}}
    end)
  end

  def get_index(agent) do
    Agent.get(agent, fn {index, _} -> index end)
  end

  def start_jet_agent(jets) do
    Agent.start_link(fn -> {0, jets} end)
  end

  def new do
    %__MODULE__{grid: MapSet.new(), highest_point: 0}
  end

  def run(%__MODULE__{} = tetris, rocks_fallen, limit, _, _) when rocks_fallen == limit,
    do: tetris

  def run(%__MODULE__{} = tetris, rocks_fallen, limit, jets, shapes) do
    shape = get_next(shapes)
    %__MODULE__{} = tetris = place_rock(tetris, shape, jets)
    run(tetris, rocks_fallen + 1, limit, jets, shapes)
  end

  def place_rock(%__MODULE__{highest_point: hp} = tetris, shape, jets) do
    left_bottom_corner = {2, hp + 4}
    rock_fall(tetris, left_bottom_corner, hp, shape, jets)
  end

  def rock_fall(%__MODULE__{} = tetris, left_bottom_corner, orig_hp, shape, jets) do
    left_bottom_corner = maybe_move_jet(tetris, get_next(jets), left_bottom_corner, shape)

    case fall_once(tetris, left_bottom_corner, shape) do
      {:cont, new_pos} -> rock_fall(tetris, new_pos, orig_hp, shape, jets)
      {:halt, %__MODULE__{} = tetris} -> tetris
    end
  end

  def fall_once(%__MODULE__{grid: grid, highest_point: hp} = tetris, {x, y}, shape) do
    shape_coords =
      shape
      |> Enum.map(fn {sx, sy} -> {x + sx, sy + y} end)

    cannot_move_down =
      shape_coords
      |> Enum.map(fn {x, y} -> {x, y - 1} end)
      |> Enum.any?(fn {_, y} = point -> MapSet.member?(grid, point) or y <= 0 end)

    if cannot_move_down do
      new_grid =
        shape_coords
        |> Enum.reduce(grid, fn coord, grid -> MapSet.put(grid, coord) end)

      new_height =
        shape_coords
        |> Enum.map(&elem(&1, 1))
        |> Enum.max()

      {:halt,
       Map.put(tetris, :grid, new_grid)
       |> Map.put(:highest_point, max(new_height, hp))}
    else
      {:cont, {x, y - 1}}
    end
  end

  def maybe_move_jet(%__MODULE__{} = tetris, jet, {x, y}, shape) do
    new_place =
      case jet do
        ">" -> {x + 1, y}
        "<" -> {x - 1, y}
      end

    if out_of_bounds?(new_place, shape) or shape_collides?(tetris, new_place, shape) do
      {x, y}
    else
      new_place
    end
  end

  def out_of_bounds?({x, y}, shape) do
    shape
    |> Enum.map(fn {sx, sy} -> {x + sx, y + sy} end)
    |> Enum.any?(fn {x, _} -> x < 0 or x >= 7 end)
  end

  def shape_collides?(%__MODULE__{grid: grid}, {x, y}, shape) do
    shape
    |> Enum.map(fn {sx, sy} -> {x + sx, y + sy} end)
    |> Enum.any?(fn point -> MapSet.member?(grid, point) end)
  end

  def run_with_history(%__MODULE__{}, rocks_fallen, limit, _, _, history)
      when rocks_fallen == limit,
      do: Enum.reverse(history)

  def run_with_history(%__MODULE__{} = tetris, rocks_fallen, limit, jets, shapes, history) do
    shape = get_next(shapes)
    %__MODULE__{highest_point: hp} = tetris = place_rock(tetris, shape, jets)
    run_with_history(tetris, rocks_fallen + 1, limit, jets, shapes, [hp | history])
  end
end

defmodule AdventOfCode.Day17 do
  alias AdventOfCode.Day17.Tetris

  def part1(args) do
    {:ok, jets} =
      args
      |> String.trim()
      |> String.codepoints()
      |> Tetris.start_jet_agent()

    {:ok, shapes} = Tetris.start_shape_agent()

    Tetris.run(Tetris.new(), 0, 2022, jets, shapes)
  end

  def part2(args) do
    {:ok, jets} =
      args
      |> String.trim()
      |> String.codepoints()
      |> Tetris.start_jet_agent()

    {:ok, shapes} = Tetris.start_shape_agent()

    history = Tetris.run_with_history(Tetris.new(), 0, 40_000, jets, shapes, [])

    [{cycle_size, freqs}] =
      1..5000
      |> Enum.map(fn bin_size ->
        bins =
          history
          |> Enum.chunk_every(bin_size)
          |> Enum.map(&Enum.sum/1)

        {bin_size,
         [[0 | bins], Enum.drop(bins, -1)]
         |> Enum.zip()
         |> Enum.map(fn {bef, curr} -> curr - bef end)
         |> Enum.frequencies()}
      end)
      |> Enum.filter(fn {_, freqs} -> map_size(freqs) <= 3 end)
      |> Enum.take(1)


    limit = 1_000_000_000_000

    first_part =
      history
      |> Enum.at(cycle_size)

    cycle_increase =
      freqs
      |> Map.keys()
      |> Enum.filter(&(Map.get(freqs, &1) > 1))
      |> Kernel.then(fn [inc] -> div(inc, cycle_size) end)


    cycles_needed = div(limit, cycle_size) - 1
    remaining_rocks = rem(limit, cycle_size)

    second_part = cycles_needed * cycle_increase
    
    third_part = 
      Enum.at(history, remaining_rocks + cycle_size) - Enum.at(history, cycle_size)

    first_part + second_part + third_part - 1
  end
end
