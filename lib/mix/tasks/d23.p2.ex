defmodule Mix.Tasks.D23.P2 do
  use Mix.Task

  import AdventOfCode.Day23

  @shortdoc "Day 23 Part 2"
  def run(args) do
    input = AdventOfCode.Input.get!(23)
    
    # input = """
    # ....#..
    # ..###.#
    # #...#.#
    # .#...##
    # #.###..
    # ##.#.##
    # .#..#..
    # """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
