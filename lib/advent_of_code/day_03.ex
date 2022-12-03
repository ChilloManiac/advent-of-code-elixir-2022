defmodule AdventOfCode.Day03 do
  def split_compartments(inventory) do
    len = String.length(inventory)
    String.split_at(inventory, div(len, 2))
  end

  def left_to_set({left, right}) do
    left_set =
      left
      |> String.graphemes()
      |> MapSet.new()

    {left_set, right}
  end

  def find_right({left_set, right}) do
    right
    |> String.graphemes()
    |> Enum.filter(&MapSet.member?(left_set, &1))
    |> List.first()
  end

  def item_to_prio(item) do
    was_upper? = String.upcase(item) == item
    lower = String.downcase(item)

    value = :binary.first(lower) - 96

    if was_upper? do
      value + 26
    else
      value
    end
  end

  def find_badge([one, two, three]) do
    first = 
      one 
      |> String.graphemes 
      |> MapSet.new
    second = 
      two
      |> String.graphemes
      |> Enum.filter(& MapSet.member?(first, &1))
      |> MapSet.new

    three
    |> String.graphemes
    |> Enum.filter(& MapSet.member?(second, &1))
    |> List.first
  end

  def part1(args) do
    args
    |> String.split()
    |> Enum.map(&split_compartments/1)
    |> Enum.map(&left_to_set/1)
    |> Enum.map(&find_right/1)
    |> Enum.map(&item_to_prio/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.split()
    |> Enum.chunk_every(3)
    |> Enum.map(&find_badge/1)
    |> Enum.map(&item_to_prio/1)
    |> Enum.sum()
  end
end
