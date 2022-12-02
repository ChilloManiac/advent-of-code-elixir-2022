defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(&calculate_score/1)
    |> Enum.sum()
  end

  defp calculate_score(round) do
    score_from_choice(round) + score_from_outcome(round)
  end

  defp score_from_choice(<<_::binary-size(2)>> <> "X"), do: 1
  defp score_from_choice(<<_::binary-size(2)>> <> "Y"), do: 2
  defp score_from_choice(<<_::binary-size(2)>> <> "Z"), do: 3

  defp score_from_outcome(<<them::binary-size(1), " ", me::binary-size(1)>>) do
    case :binary.first(me) - :binary.first(them) do
      win when win in [24, 21] -> 6
      23 -> 3 
      _ -> 0
    end
  end

  def part2(args) do
    args
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(&calculate_score_two/1)
    |> Enum.sum()
  end

  defp calculate_score_two(round) do
    score_from_choice_two(round) + score_from_outcome_two(round)
  end

  @matrix %{
    "A" => [loose: 3, draw: 1, win: 2],
    "B" => [loose: 1, draw: 2, win: 3],
    "C" => [loose: 2, draw: 3, win: 1],
  }

  defp score_from_choice_two(round) do
    case String.split(round) do
      [choice, "X"] -> Map.get(@matrix, choice) |> Keyword.get(:loose)
      [choice, "Y"] -> Map.get(@matrix, choice) |> Keyword.get(:draw)
      [choice, "Z"] -> Map.get(@matrix, choice) |> Keyword.get(:win)
    end 
  end

  defp score_from_outcome_two(<<_::binary-size(2)>> <> "X"), do: 0
  defp score_from_outcome_two(<<_::binary-size(2)>> <> "Y"), do: 3
  defp score_from_outcome_two(<<_::binary-size(2)>> <> "Z"), do: 6

end
