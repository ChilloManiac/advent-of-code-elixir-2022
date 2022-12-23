defmodule AdventOfCode.Day22.Grove do
  defstruct ~w(height width map pos)a

  def new do
    %__MODULE__{
      height: 0,
      width: 0,
      map: Map.new(),
      pos: nil
    }
  end

  def add_line(line, %__MODULE__{} = grove) do
    as_chars =
      line
      |> String.codepoints()

    as_chars
    |> Enum.with_index(1)
    |> Enum.reduce(grove, fn {char, column}, %__MODULE__{height: h} = grove ->
      case char do
        " " -> grove
        "." -> Map.update!(grove, :map, fn map -> Map.put(map, {column, h + 1}, :empty) end)
        "#" -> Map.update!(grove, :map, fn map -> Map.put(map, {column, h + 1}, :rock) end)
      end
    end)
    |> Kernel.then(fn grove -> Map.update!(grove, :height, &(&1 + 1)) end)
    |> Kernel.then(fn grove -> Map.update!(grove, :width, &max(&1, length(as_chars))) end)
  end

  def set_inital_position(%__MODULE__{map: map} = grove) do
    [pos] =
      Stream.iterate(1, &(&1 + 1))
      |> Stream.filter(fn col -> Map.get(map, {col, 1}) == :empty end)
      |> Stream.take(1)
      |> Enum.to_list()

    Map.put(grove, :pos, {{pos, 1}, :east})
  end

  def run(%__MODULE__{} = grove, []), do: grove
  def run(%__MODULE__{} = grove, [0 | is]), do: run(grove, is)

  def run(%__MODULE__{pos: {coords, facing}} = grove, ["L" | is]) do
    facing =
      case facing do
        :east -> :north
        :north -> :west
        :west -> :south
        :south -> :east
      end

    Map.put(grove, :pos, {coords, facing})
    |> run(is)
  end

  def run(%__MODULE__{pos: {coords, facing}} = grove, ["R" | is]) do
    facing =
      case facing do
        :north -> :east
        :west -> :north
        :south -> :west
        :east -> :south
      end

    Map.put(grove, :pos, {coords, facing})
    |> run(is)
  end

  def run(%__MODULE__{} = grove, [i | is]) when is_integer(i) do
    grove = step(grove)
    run(grove, [i - 1 | is])
  end

  def run(%__MODULE__{} = grove, [i | is]) when is_binary(i) do
    i = String.to_integer(i)

    run(grove, [i | is])
  end

  def visualize(%__MODULE__{map: m, pos: {{col, row}, _}}) do
    for r <- (row - 6)..(row + 6), c <- (col - 6)..(col + 6) do
      {c, r}
    end
    |> Enum.map(fn
      {^col, ^row} ->
        "X"

      coord ->
        case Map.get(m, coord) do
          nil -> " "
          :empty -> "."
          :rock -> "#"
        end
    end)
    |> Enum.chunk_every(13)
    |> Enum.map(&Enum.join/1)
    |> Enum.each(&IO.puts/1)

    :timer.sleep(100)
  end

  def step(%__MODULE__{map: m, pos: {pos, facing}} = grove) do
    next_place = find_next_coord(pos, grove)

    case Map.get(m, next_place) do
      :rock -> grove
      :empty -> Map.put(grove, :pos, {next_place, facing})
    end
  end

  def find_next_coord({col, row}, %__MODULE__{map: m, width: w, pos: {_, :east}} = grove) do
    case Map.get(m, {col + 1, row}) do
      nil -> find_next_coord({Integer.mod(col + 1, w + 2), row}, grove)
      _ -> {col + 1, row}
    end
  end

  def find_next_coord({col, row}, %__MODULE__{map: m, width: w, pos: {_, :west}} = grove) do
    case Map.get(m, {col - 1, row}) do
      nil -> find_next_coord({Integer.mod(col - 1, w + 2), row}, grove)
      _ -> {col - 1, row}
    end
  end

  def find_next_coord({col, row}, %__MODULE__{map: m, height: h, pos: {_, :north}} = grove) do
    case Map.get(m, {col, row - 1}) do
      nil -> find_next_coord({col, Integer.mod(row - 1, h + 2)}, grove)
      _ -> {col, row - 1}
    end
  end


  def find_next_coord({col, row}, %__MODULE__{map: m, height: h, pos: {_, :south}} = grove) do
    case Map.get(m, {col, row + 1}) do
      nil -> find_next_coord({col, Integer.mod(row + 1, h + 2)}, grove)
      _ -> {col, row + 1}
    end
  end

  def score(%__MODULE__{pos: {{col, row}, facing}}) do
    facing_value =
      case facing do
        :east -> 0
        :south -> 1
        :west -> 2
        :north -> 3
      end

    1000 * row + 4 * col + facing_value
  end
end

defmodule AdventOfCode.Day22 do
  alias AdventOfCode.Day22.Grove

  def part1(args) do
    [map, instructions] =
      args
      |> String.split("\n\n", trim: true)

    map =
      map
      |> String.split("\n", trim: true)
      |> Enum.reduce(Grove.new(), &Grove.add_line/2)
      |> Kernel.then(&Grove.set_inital_position/1)

    instructions =
      instructions
      |> String.trim()
      |> String.split("R", trim: true)
      |> Enum.intersperse("R")
      |> Enum.flat_map(&(String.split(&1, "L", trim: true) |> Enum.intersperse("L")))


    Grove.run(map, instructions)
    |> Grove.score()
  end

  def part2(args) do
  end
end
