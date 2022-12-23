defmodule Mix.Tasks.D21.P2 do
  use Mix.Task

  import AdventOfCode.Day21

  @shortdoc "Day 21 Part 2"
  def run(args) do
    # input = """
    # root: pppw + sjmn
    # dbpl: 5
    # cczh: sllz + lgvd
    # zczc: 2
    # ptdq: humn - dvpt
    # dvpt: 3
    # lfqf: 4
    # humn: 5
    # ljgn: 2
    # sjmn: drzm * dbpl
    # sllz: 4
    # pppw: cczh / lfqf
    # lgvd: ljgn * ptdq
    # drzm: hmdt - zczc
    # hmdt: 32
    # """

    input = AdventOfCode.Input.get!(21)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
