defmodule AdventOfCode.Day01 do
  defp split_elves(binary) do
    String.split(binary, "\n\n")
  end

  defp to_num_array(elves) do
    Enum.map(elves, fn elf ->
      Enum.map(elf, fn calories_string ->
        {value, ""} = Integer.parse(calories_string)
        value
      end)
    end)
  end

  def part1(args) do
    args
    |> split_elves
    |> Enum.map(fn elf -> String.split(elf) end)
    |> to_num_array
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(1)
    |> Enum.sum
  end

  def part2(args) do
    args
    |> split_elves
    |> Enum.map(fn elf -> String.split(elf) end)
    |> to_num_array
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum
  end
end
