defmodule AdventOfCode.Day10.Emulator do
  defstruct ~w(register_history register)a

  def new do
    %__MODULE__{register_history: [], register: 1}
  end

  def handle_instruction(line, %__MODULE__{register: regx} = emulator) do
    case line do
      "noop" ->
        Map.update!(emulator, :register_history, fn hist -> [regx | hist] end)

      "addx " <> val ->
        val = String.to_integer(val)

        emulator
        |> Map.update!(:register_history, fn hist -> [regx | hist] end)
        |> Map.update!(:register_history, fn hist -> [regx | hist] end)
        |> Map.update!(:register, fn regx -> regx + val end)
    end
  end

  def value_at(%__MODULE__{register_history: hist}, index) do
    Enum.at(hist, -index)
  end
end

defmodule AdventOfCode.Day10 do
  alias AdventOfCode.Day10.Emulator

  def part1(args) do
    emulator =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Emulator.new(), &Emulator.handle_instruction/2)

    20..220//40
    |> Enum.map(&(Emulator.value_at(emulator, &1) * &1))
    |> Enum.sum()
    |> dbg
  end

  def part2(args) do
    emulator =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(Emulator.new(), &Emulator.handle_instruction/2)
    

    1..length(emulator.register_history)
    |> Enum.map(fn cycle_number -> {Emulator.value_at(emulator, cycle_number), cycle_number} end)
    |> Enum.map(fn {register, cycle_number} -> 
      pixel_pos = rem((cycle_number - 1), 40)
      if abs(register - pixel_pos) <= 1 do
        "#"
      else 
        "."
      end
    end)
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts
  end
end
