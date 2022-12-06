defmodule AdventOfCode.Day06 do
  def find_sop_marker([_head | tail] = line, distinct, value) do
    line
    |> Enum.take(distinct)
    |> MapSet.new()
    |> MapSet.size()
    |> Kernel.then(fn amount ->
      case amount do
        ^distinct -> value
        _ -> find_sop_marker(tail, distinct, value + 1)
      end
    end)
  end

  def part1(args) do
    args
    |> String.graphemes()
    |> find_sop_marker(4, 4)
  end

  def part2(args) do
    args
    |> String.graphemes()
    |> find_sop_marker(14, 14)
  end
end
