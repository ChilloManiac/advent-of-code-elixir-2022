defmodule AdventOfCode.Day19 do
  use Memoize

  def parse_blueprint(line) do
    ["Blueprint " <> blueprint, rest] = String.split(line, ":", trim: true)
    blueprint = String.to_integer(blueprint)

    [ore_ore, clay_ore, obs_ore, obs_clay, geo_ore, geo_obs] =
      rest
      |> String.split(" ", trim: true)
      |> Enum.filter(fn str ->
        try do
          _ = String.to_integer(str)
          true
        rescue
          ArgumentError ->
            false
        end
      end)
      |> Enum.map(&String.to_integer/1)

    %{
      blueprint_num: blueprint,
      ore: %{ore: ore_ore},
      clay: %{ore: clay_ore},
      obsidian: %{ore: obs_ore, clay: obs_clay},
      geode: %{ore: geo_ore, obsidian: geo_obs}
    }
  end

  def bots_map do
    %{
      ore: 1,
      clay: 0,
      obsidian: 0,
      geode: 0
    }
  end

  def resource_map do
    %{
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0
    }
  end

  def can_build?(%{clay: 0}), do: [:clay, :ore]
  def can_build?(%{obsidian: 0}), do: [:obsidian, :ore, :clay]
  def can_build?(_), do: [:geode, :obsidian, :clay, :ore]

  def options(bots, %{ore: orep, clay: clayp, obsidian: obsp, geode: geop}) do
    prices = [orep, clayp, obsp, geop]

    required_amount =
      [:obs, :clay, :ore]
      |> Enum.map(fn type ->
        prices
        |> Enum.map(fn p -> Map.get(p, type, 0) end)
        |> Enum.max()
        |> Kernel.then(&{type, &1})
      end)

    can_build?(bots)
    |> Enum.reject(fn type ->
      type != :geode and Map.get(bots, type) >= Keyword.get(required_amount, type)
    end)
  end

  def has_resources_for_bot?(bot, resources, blue_print) do
    price = Map.get(blue_print, bot)

    price
    |> Map.keys()
    |> Enum.map(&(Map.get(price, &1) <= Map.get(resources, &1)))
    |> Enum.all?()
  end

  def build_bot(bot, bots, resources, blue_print) do
    price = Map.get(blue_print, bot)

    resources = Map.merge(resources, price, fn _, r, p -> r - p end)

    bots = Map.update!(bots, bot, &(&1 + 1))

    {resources, bots}
  end

  def calc_quality_level(%{blueprint_num: bp_id} = blueprint, minutes_left) do
    options(bots_map(), blueprint)
    |> Enum.map(&simulate_blueprint(minutes_left, bots_map(), resource_map(), blueprint, &1))
    |> Enum.max()
    |> Kernel.then(&{bp_id, &1})
  end

  def simulate_blueprint(0, _, %{geode: geodes}, _, _) do
    geodes
  end

  def simulate_blueprint(minutes_left, bots, resources, blueprint, bot_to_build) do
    if has_resources_for_bot?(bot_to_build, resources, blueprint) do
      {resources, next_bots} = build_bot(bot_to_build, bots, resources, blueprint)
      resources = harvest(resources, bots)

      if minutes_left > 20 do
        options(next_bots, blueprint)
        |> Task.async_stream(
          &simulate_blueprint(minutes_left - 1, next_bots, resources, blueprint, &1),
          timeout: :infinity
        )
        |> Enum.map(fn {:ok, geodes} -> geodes end)
        |> Enum.max()
      else
        options(next_bots, blueprint)
        |> Enum.map(&simulate_blueprint(minutes_left - 1, next_bots, resources, blueprint, &1))
        |> Enum.max()
      end
    else
      resources = harvest(resources, bots)
      simulate_blueprint(minutes_left - 1, bots, resources, blueprint, bot_to_build)
    end
  end

  def harvest(resources, bots) do
    Map.merge(resources, bots, fn _, left, right -> left + right end)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_blueprint/1)
    |> Task.async_stream(&calc_quality_level(&1, 24), timeout: :infinity)
    |> Enum.map(fn {:ok, {id, geodes}} -> id * geodes end)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.take(3)
    |> Enum.map(&parse_blueprint/1)
    |> Task.async_stream(&calc_quality_level(&1, 32), timeout: :infinity)
    |> Enum.map(fn {:ok, {_id, geodes}} -> geodes end)
    |> Enum.product()
  end
end
