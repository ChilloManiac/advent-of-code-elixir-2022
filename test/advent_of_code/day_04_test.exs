defmodule AdventOfCode.Day04Test do
  use ExUnit.Case

  import AdventOfCode.Day04

  test "part1" do
    input = AdventOfCode.Input.get!(4)
    result = part1(input)

    assert result == 305
  end

  test "part2" do
    input = AdventOfCode.Input.get!(4)
    result = part2(input)

    assert result == 811
  end
end
