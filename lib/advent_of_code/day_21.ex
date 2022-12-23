defmodule AdventOfCode.Day21 do
  def monkey_agent do
    {:ok, pid} = Agent.start(fn -> %{} end)
    pid
  end

  def add_monkey(agent, line) do
    <<this::binary-size(4), ": ", rest::binary>> = line

    case rest do
      <<left::binary-size(4), " ", op::binary-size(1), " ", right::binary-size(4)>> ->
        set_monkey(agent, this, left, op, right)

      num_str ->
        num = String.to_integer(num_str)
        set_monkey(agent, this, num)
    end
  end

  def set_monkey(agent, this, num) do
    Agent.update(agent, fn monkeys -> Map.put(monkeys, this, num) end)
  end

  def set_monkey(agent, this, left, op, right) do
    Agent.update(agent, fn monkeys -> Map.put(monkeys, this, {left, op, right}) end)
  end

  def get_monkey(agent, name) do
    Agent.get(agent, fn monkeys -> Map.get(monkeys, name) end)
  end

  def resolve_monkey(monkeys, "root") do
    case get_monkey(monkeys, "root") do
      {left, _, right} ->
        left = resolve_monkey(monkeys, left)
        right = resolve_monkey(monkeys, right)

        left - right
    end
  end

  def resolve_monkey(monkeys, name) do
    case get_monkey(monkeys, name) do
      num when is_integer(num) ->
        num

      {left, op, right} ->
        left = resolve_monkey(monkeys, left)
        right = resolve_monkey(monkeys, right)

        result =
          case op do
            "-" -> left - right
            "+" -> left + right
            "*" -> left * right
            "/" -> div(left, right)
          end

        set_monkey(monkeys, name, result)
        result
    end
  end

  def part1(args) do
    monkeys = monkey_agent()

    args
    |> String.split("\n", trim: true)
    |> Enum.each(fn line -> add_monkey(monkeys, line) end)

    resolve_monkey(monkeys, "root")
  end

  def another_one(lines, monkeys, upper, lower) do
    Enum.each(lines, fn line -> add_monkey(monkeys, line) end)

    pivot = div(upper - lower, 2) + lower
    set_monkey(monkeys, "humn", pivot)
    result = resolve_monkey(monkeys, "root")
    dbg({pivot, result})

    case result do
      num when num == 0 -> pivot
      num when num > 0 -> another_one(lines, monkeys, pivot, lower)
      num when num < 0 -> another_one(lines, monkeys, upper, pivot)
    end
  end

  def part2(args) do
    monkeys = monkey_agent()
    args
    |> String.split("\n", trim: true)
    |> another_one(monkeys, 0, 10_000_000_000_000)
  end
end
