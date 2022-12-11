defmodule AdventOfCode.Day11.Monkey do
  defstruct ~w(items operation predicate throw_if_true throw_if_false inspections)a

  def parse_items("Starting items: " <> items) do
    items
    |> String.split(", ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_operation("Operation: new = " <> expr) do
    case expr do
      "old * old" ->
        fn old -> old * old end

      "old + " <> val ->
        fn old ->
          val = String.to_integer(val)
          old + val
        end

      "old * " <> val ->
        fn old ->
          val = String.to_integer(val)
          old * val
        end
    end
  end

  def parse_predicate("Test: divisible by " <> val) do
    val = String.to_integer(val)
    fn a -> rem(a, val) == 0 end
  end

  def parse_throw(string) do
    string
    |> String.split(" ", trim: true)
    |> Enum.at(-1)
    |> String.to_integer()
  end

  def parse(string) do
    [_monkey, item_string, op_string, pred_string, true_string, false_string] =
      String.split(string, "\n", trim: true) |> Enum.map(&String.trim/1)

    starting_items = parse_items(item_string)
    operation = parse_operation(op_string)
    predicate = parse_predicate(pred_string)
    throw_if_true = parse_throw(true_string)
    throw_if_false = parse_throw(false_string)

    %__MODULE__{
      items: starting_items,
      operation: operation,
      predicate: predicate,
      throw_if_true: throw_if_true,
      throw_if_false: throw_if_false,
      inspections: 0
    }
  end

  def monkey_throw(monkey_number, monkey_map) do
    %__MODULE__{
      items: items,
      operation: operation,
      predicate: predicate,
      throw_if_true: throw_if_true,
      throw_if_false: throw_if_false
    } = Map.get(monkey_map, monkey_number)

    new_inspections = items |> length

    after_throwing =
      items
      |> Enum.map(&operation.(&1))
      #|> Enum.map(&div(&1, 3)) # for part 1
      |> Enum.map(&rem(&1, 9699690)) # for part 2
      |> Enum.map(fn worry_level ->
        if predicate.(worry_level) do
          {throw_if_true, worry_level}
        else
          {throw_if_false, worry_level}
        end
      end)
      |> Enum.reduce(monkey_map, fn {throw_to, worry_level}, monkey_map ->
        Map.update!(monkey_map, throw_to, fn monkey ->
          Map.update!(monkey, :items, fn items -> items ++ [worry_level] end)
        end)
      end)

    after_throwing
    |> Map.update!(monkey_number, fn monkey ->
      Map.put(monkey, :items, [])
      |> Map.update!(:inspections, &(&1 + new_inspections))
    end)
  end

  def monkey_shuffle(monkey_map) do
    0..(map_size(monkey_map) - 1)
    |> Enum.reduce(monkey_map, fn monkey_num, monkey_map ->
      monkey_throw(monkey_num, monkey_map)
    end)
  end
end

defmodule AdventOfCode.Day11 do
  alias __MODULE__.Monkey

  def part1(args) do
    monkey_map =
      args
      |> String.split("\n\n", trim: true)
      |> Enum.map(&Monkey.parse/1)
      |> Enum.with_index()
      |> Enum.map(fn {monkey, index} -> {index, monkey} end)
      |> Enum.into(%{})

    1..20
    |> Enum.reduce(monkey_map, fn _, monkey_map -> 
      Monkey.monkey_shuffle(monkey_map)
    end)
    |> Map.values
    |> Enum.map(fn monkey -> Map.get(monkey, :inspections) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(& &1 * &2)
    |> dbg
  end

  def part2(args) do
    monkey_map =
      args
      |> String.split("\n\n", trim: true)
      |> Enum.map(&Monkey.parse/1)
      |> Enum.with_index()
      |> Enum.map(fn {monkey, index} -> {index, monkey} end)
      |> Enum.into(%{})

    1..10_000
    |> Enum.reduce(monkey_map, fn _, monkey_map -> 
      Monkey.monkey_shuffle(monkey_map)
    end)
    |> Map.values
    |> Enum.map(fn monkey -> Map.get(monkey, :inspections) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(& &1 * &2)
  end
end
