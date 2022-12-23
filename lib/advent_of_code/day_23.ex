defmodule AdventOfCode.Day23.Farm do
  defstruct ~w(elfs height order)a

  def new do
    %__MODULE__{
      elfs: MapSet.new(),
      height: 0,
      order: [:N, :S, :W, :E]
    }
  end

  def parse_line(line, %__MODULE__{elfs: elfs, height: height} = farm) do
    elfs =
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(elfs, fn
        {"#", index}, elfs -> MapSet.put(elfs, {index, height})
        {".", _}, elfs -> elfs
      end)

    farm
    |> Map.put(:elfs, elfs)
    |> Map.put(:height, height + 1)
  end

  def visualize(%__MODULE__{elfs: elfs} = farm, x0, x1, y0, y1) do
    for y <- y0..y1, x <- x0..x1 do
      {x, y}
    end
    |> Enum.chunk_by(fn {_x, y} -> y end)
    |> Enum.map(fn coords ->
      Enum.map(coords, fn coord ->
        cond do
          MapSet.member?(elfs, coord) -> "#"
          true -> " "
        end
      end)
      |> Enum.join()
    end)
    |> Enum.each(&IO.puts/1)

    farm
  end

  def step_until(%__MODULE__{} = farm, acc) do
    proposed_steps = make_proposed_steps(farm)

    amount_new =
      proposed_steps
      |> Enum.filter(fn {from, to} -> from != to end)
      |> then(fn lst -> length(lst) end)

    if amount_new == 0 do
      acc + 1
    else
      step_freqs =
        proposed_steps
        |> Enum.frequencies_by(fn {_, to} -> to end)

      elfs =
        proposed_steps
        |> Enum.map(fn {from, to} ->
          case Map.get(step_freqs, to) do
            n when n > 1 -> from
            n when n == 1 -> to
          end
        end)
        |> MapSet.new()

      farm
      |> Map.put(:elfs, elfs)
      |> Map.update!(:order, fn [a, b, c, d] -> [b, c, d, a] end)
      |> step_until(acc + 1)
    end
  end

  def n_steps(%__MODULE__{} = farm, 0), do: farm

  def n_steps(%__MODULE__{} = farm, n) do
    proposed_steps = make_proposed_steps(farm)

    step_freqs =
      proposed_steps
      |> Enum.frequencies_by(fn {_, to} -> to end)

    elfs =
      proposed_steps
      |> Enum.map(fn {from, to} ->
        case Map.get(step_freqs, to) do
          n when n > 1 -> from
          n when n == 1 -> to
        end
      end)
      |> MapSet.new()

    farm
    |> Map.put(:elfs, elfs)
    |> Map.update!(:order, fn [a, b, c, d] -> [b, c, d, a] end)
    |> n_steps(n - 1)
  end

  def make_proposed_steps(%__MODULE__{elfs: elfs, order: order}) do
    elfs
    |> MapSet.to_list()
    |> Enum.map(fn elf -> make_proposed_step(elf, elfs, order) end)
  end

  def make_proposed_step({x, y} = from, elfs, order) do
    nb = for nx <- (x - 1)..(x + 1), ny <- (y - 1)..(y + 1), {x, y} != {nx, ny}, do: {nx, ny}

    should_move =
      nb
      |> Enum.any?(&MapSet.member?(elfs, &1))

    if not should_move do
      {from, from}
    else
      to = find_direction(from, elfs, order)
      {from, to}
    end
  end

  def find_direction({x, y}, elfs, [:N | tail]) do
    to_check = for nx <- (x - 1)..(x + 1), do: {nx, y - 1}

    has_room = Enum.all?(to_check, &(not MapSet.member?(elfs, &1)))

    if has_room, do: {x, y - 1}, else: find_direction({x, y}, elfs, tail)
  end

  def find_direction({x, y}, elfs, [:S | tail]) do
    to_check = for nx <- (x - 1)..(x + 1), do: {nx, y + 1}

    has_room = Enum.all?(to_check, &(not MapSet.member?(elfs, &1)))

    if has_room, do: {x, y + 1}, else: find_direction({x, y}, elfs, tail)
  end

  def find_direction({x, y}, elfs, [:W | tail]) do
    to_check = for ny <- (y - 1)..(y + 1), do: {x - 1, ny}

    has_room = Enum.all?(to_check, &(not MapSet.member?(elfs, &1)))

    if has_room, do: {x - 1, y}, else: find_direction({x, y}, elfs, tail)
  end

  def find_direction({x, y}, elfs, [:E | tail]) do
    to_check = for ny <- (y - 1)..(y + 1), do: {x + 1, ny}

    has_room = Enum.all?(to_check, &(not MapSet.member?(elfs, &1)))

    if has_room, do: {x + 1, y}, else: find_direction({x, y}, elfs, tail)
  end

  def find_direction(pos, _, []), do: pos

  def smallest_square(%__MODULE__{elfs: elfs}) do
    elfs
    |> MapSet.to_list()
    |> Enum.reduce(
      %{
        x_min: 100_000,
        x_max: -100_000,
        y_min: 100_000,
        y_max: -100_000
      },
      fn {x, y}, results ->
        results
        |> Map.update!(:x_min, &min(&1, x))
        |> Map.update!(:x_max, &max(&1, x))
        |> Map.update!(:y_min, &min(&1, y))
        |> Map.update!(:y_max, &max(&1, y))
      end
    )
  end
end

defmodule AdventOfCode.Day23 do
  alias AdventOfCode.Day23.Farm

  def part1(args) do
    farm =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Farm.new(), &Farm.parse_line/2)

    farm =
      farm
      |> Farm.n_steps(10)

    %{x_min: x_min, x_max: x_max, y_min: y_min, y_max: y_max} = Farm.smallest_square(farm)

    (x_max - x_min + 1) * (y_max - y_min + 1) - MapSet.size(Map.get(farm, :elfs))
  end

  def part2(args) do
    farm =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Farm.new(), &Farm.parse_line/2)

    farm
    |> Farm.step_until(0)
  end
end
