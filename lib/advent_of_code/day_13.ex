defmodule AdventOfCode.Day13 do
  def order?({left, right}) when is_integer(left) and is_integer(right) and left < right,
    do: true

  def order?({left, right}) when is_integer(left) and is_integer(right) and left > right,
    do: false

  def order?({left, right}) when is_integer(left) and is_integer(right) and left == right,
    do: :cont

  def order?({left, right}) when is_integer(left) and is_list(right), do: order?({[left], right})
  def order?({left, right}) when is_integer(right) and is_list(left), do: order?({left, [right]})
  def order?({[], []}), do: :cont
  def order?({[], [_ | _]}), do: true
  def order?({[_ | _], []}), do: false

  def order?({[left_head | left_tail], [right_head | right_tail]}) do
    case order?({left_head, right_head}) do
      :cont -> order?({left_tail, right_tail})
      bool -> bool
    end
  end

  def make_pair(lines) do
    [left, right] = String.split(lines) |> Enum.map(&Code.eval_string/1) |> Enum.map(&elem(&1, 0))
    {left, right}
  end

  def make_line(line) do
    line
    |> Code.eval_string()
    |> Kernel.then(&elem(&1, 0))
  end

  def part1(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(&make_pair/1)
    |> Enum.with_index(1)
    |> Enum.map(fn {pair, index} -> {order?(pair), index} end)
    |> Enum.filter(fn {is_ordered, _} -> is_ordered end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.sum()
  end

  def part2(args) do
    divider_packets = [[[2]], [[6]]]

    ordered_list =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&make_line/1)
      |> Enum.concat(divider_packets)
      |> Enum.sort(fn left, right -> order?({left, right}) end)

    first = Enum.find_index(ordered_list, &(&1 == [[2]])) + 1
    second = Enum.find_index(ordered_list, &(&1 == [[6]])) + 1

    first * second
  end
end
