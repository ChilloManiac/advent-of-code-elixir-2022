defmodule Mix.Tasks.D16.P2 do
  use Mix.Task

  import AdventOfCode.Day16

  @shortdoc "Day 16 Part 2"
  def run(args) do
    input = """
    Valve AW has flow rate=0; tunnels lead to valves LG, TL
    Valve OM has flow rate=0; tunnels lead to valves XK, IM
    Valve BG has flow rate=0; tunnels lead to valves MP, SB
    Valve XB has flow rate=0; tunnels lead to valves MA, TL
    Valve CD has flow rate=0; tunnels lead to valves VL, OF
    Valve VF has flow rate=0; tunnels lead to valves CS, XK
    Valve HK has flow rate=0; tunnels lead to valves RL, QB
    Valve QN has flow rate=0; tunnels lead to valves IV, QR
    Valve OF has flow rate=4; tunnels lead to valves TQ, CD, IR, IM, JE
    Valve QB has flow rate=14; tunnels lead to valves HK, XE, CS, VO
    Valve ZE has flow rate=7; tunnels lead to valves JB, NC, SE, OI
    Valve OW has flow rate=0; tunnels lead to valves MB, JB
    Valve MA has flow rate=0; tunnels lead to valves XB, MB
    Valve MP has flow rate=0; tunnels lead to valves VK, BG
    Valve UE has flow rate=9; tunnels lead to valves ZM, RZ, WI, HO, FO
    Valve QR has flow rate=24; tunnel leads to valve QN
    Valve TQ has flow rate=0; tunnels lead to valves OF, AA
    Valve SE has flow rate=0; tunnels lead to valves ZE, ZZ
    Valve AQ has flow rate=20; tunnel leads to valve CX
    Valve XE has flow rate=0; tunnels lead to valves JQ, QB
    Valve DC has flow rate=8; tunnels lead to valves ZD, MJ, RZ
    Valve ZM has flow rate=0; tunnels lead to valves YJ, UE
    Valve VK has flow rate=21; tunnel leads to valve MP
    Valve VR has flow rate=0; tunnels lead to valves WV, PS
    Valve BH has flow rate=0; tunnels lead to valves AA, MB
    Valve ZR has flow rate=0; tunnels lead to valves LG, AI
    Valve JE has flow rate=0; tunnels lead to valves OF, HO
    Valve IR has flow rate=0; tunnels lead to valves IV, OF
    Valve FO has flow rate=0; tunnels lead to valves XQ, UE
    Valve AA has flow rate=0; tunnels lead to valves NC, VY, BH, TQ, YJ
    Valve ZZ has flow rate=0; tunnels lead to valves SE, TL
    Valve XQ has flow rate=0; tunnels lead to valves IV, FO
    Valve WI has flow rate=0; tunnels lead to valves UE, VO
    Valve VY has flow rate=0; tunnels lead to valves AA, LG
    Valve XK has flow rate=15; tunnels lead to valves VF, OM, ZD
    Valve CX has flow rate=0; tunnels lead to valves AQ, MB
    Valve JQ has flow rate=0; tunnels lead to valves XE, IV
    Valve LG has flow rate=3; tunnels lead to valves VY, PS, ZR, AW, OI
    Valve JB has flow rate=0; tunnels lead to valves ZE, OW
    Valve OI has flow rate=0; tunnels lead to valves ZE, LG
    Valve YJ has flow rate=0; tunnels lead to valves ZM, AA
    Valve NC has flow rate=0; tunnels lead to valves AA, ZE
    Valve KR has flow rate=0; tunnels lead to valves SB, MJ
    Valve MB has flow rate=17; tunnels lead to valves CX, BH, AI, OW, MA
    Valve AI has flow rate=0; tunnels lead to valves ZR, MB
    Valve TL has flow rate=16; tunnels lead to valves ZZ, XB, AW
    Valve RL has flow rate=0; tunnels lead to valves WV, HK
    Valve CS has flow rate=0; tunnels lead to valves VF, QB
    Valve WV has flow rate=25; tunnels lead to valves RL, VL, VR
    Valve ZD has flow rate=0; tunnels lead to valves XK, DC
    Valve IV has flow rate=23; tunnels lead to valves XQ, IR, JQ, QN
    Valve PS has flow rate=0; tunnels lead to valves VR, LG
    Valve RZ has flow rate=0; tunnels lead to valves DC, UE
    Valve VO has flow rate=0; tunnels lead to valves WI, QB
    Valve MJ has flow rate=0; tunnels lead to valves DC, KR
    Valve IM has flow rate=0; tunnels lead to valves OM, OF
    Valve VL has flow rate=0; tunnels lead to valves CD, WV
    Valve SB has flow rate=18; tunnels lead to valves BG, KR
    Valve HO has flow rate=0; tunnels lead to valves JE, UE
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
