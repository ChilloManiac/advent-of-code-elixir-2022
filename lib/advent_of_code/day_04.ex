defmodule AdventOfCode.Day04 do
  defp to_indexes(range) do
    [left, right] = String.split(range, "-")
    {left, ""} = Integer.parse(left)
    {right, ""} = Integer.parse(right)

    for x <- left..right do
      x
    end
  end

  defp is_subset_of?(inner, outer) do
    inner = MapSet.new(inner)
    outer = MapSet.new(outer)
    MapSet.subset?(inner, outer)
  end

  defp overlaps?(left, right) do
    left = MapSet.new(left)
    right = MapSet.new(right)

    intersection =
      MapSet.intersection(left, right)
      |> MapSet.size()

    intersection > 0
  end

  def part1(args) do
    args
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [left, right] -> {to_indexes(left), to_indexes(right)} end)
    |> Enum.map(fn {left, right} -> is_subset_of?(right, left) or is_subset_of?(left, right) end)
    |> Enum.filter(& &1)
    |> length
  end

  def part2(args) do
    args
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [left, right] -> {to_indexes(left), to_indexes(right)} end)
    |> Enum.map(fn {left, right} -> overlaps?(left, right) end)
    |> Enum.filter(& &1)
    |> length
  end
end
