defmodule AdventOfCode.Day05 do

  defp single_move([fhead | ftail], to_stack) do
    {ftail, [fhead | to_stack]} 
  end

  defp move([0, _, _], stacks), do: stacks
  defp move([amount, from, to], stacks) do
    from_stack = Map.get(stacks, from)
    to_stack = Map.get(stacks, to)

    {new_from, new_to} = single_move(from_stack, to_stack)
    stacks =
      stacks 
      |> Map.put(from, new_from)
      |> Map.put(to, new_to)


    move([amount - 1, from, to], stacks)
  end

  defp move9001([amount, from, to], stacks) do
    from_stack = Map.get(stacks, from)
    to_stack = Map.get(stacks, to)

    {popped, new_from} = Enum.split(from_stack, amount)
    new_to = popped ++ to_stack

    stacks 
    |> Map.put(from, new_from)
    |> Map.put(to, new_to)
  end

  def part1(stacks, moves) do
    movesets = moves |> Enum.chunk_every(3)

    stacks_as_lists = 
      stacks
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index(1)
      |> Enum.map(fn {left, right} -> {right, left} end)
      |> Enum.into(%{})

    # ["V", "P", "C", "D", "M", "S", "L", "W", "J"]
  
    movesets
    |> Enum.reduce(stacks_as_lists, &move/2)
    |> Map.values
    |> Enum.map(&hd/1)
  end

  def part2(stacks, moves) do
    movesets = moves |> Enum.chunk_every(3)

    stacks_as_lists = 
      stacks
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index(1)
      |> Enum.map(fn {left, right} -> {right, left} end)
      |> Enum.into(%{})

    movesets
    |> Enum.reduce(stacks_as_lists, &move9001/2)
    |> Map.values
    |> Enum.map(&hd/1)

    # Part 2 Results: ["T", "P", "W", "C", "G", "N", "C", "C", "G"]
  end
end
