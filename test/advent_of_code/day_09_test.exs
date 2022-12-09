defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  test "part1" do
    input = AdventOfCode.Input.get!(9)
    result = part1(input)

    assert result == 6057
  end

  test "part2" do
    input = AdventOfCode.Input.get!(9)
    result = part2(input)

    assert result == 2514
  end
end
