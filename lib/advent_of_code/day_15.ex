defmodule AdventOfCode.Day15.Sensor do
  defstruct ~w(x y range)a

  def new(x, y, range) do
    %__MODULE__{x: x, y: y, range: range}
  end
end

defmodule AdventOfCode.Day15.Container do
  defstruct ~w(sensors beacons hx hy lx ly)a

  alias AdventOfCode.Day15.Sensor

  def new do
    %__MODULE__{sensors: Map.new(), beacons: MapSet.new(), hx: 0, hy: 0, lx: 0, ly: 0}
  end

  def parse_line(line, %__MODULE__{hx: hx, hy: hy, lx: lx, ly: ly} = container) do
    [sensor_line, beacon_line] = String.split(line, ": ", trim: true)
    {sx, sy} = parse_sensor(sensor_line)
    {bx, by} = parse_beacon(beacon_line)
    range = distance(sx, sy, bx, by)

    sensor = Sensor.new(sx, sy, range)

    lx = min(lx, sx - range)
    ly = min(ly, sy - range)
    hx = max(hx, sx + range)
    hy = max(hy, sy + range)

    container
    |> Map.update!(:sensors, &Map.put(&1, {sx, sy}, sensor))
    |> Map.update!(:beacons, &MapSet.put(&1, {bx, by}))
    |> Map.put(:lx, lx)
    |> Map.put(:ly, ly)
    |> Map.put(:hx, hx)
    |> Map.put(:hy, hy)
  end

  def parse_sensor("Sensor at " <> coords), do: parse_coords(coords)
  def parse_beacon("closest beacon is at " <> coords), do: parse_coords(coords)

  def parse_coords(coord_string) do
    ["x=" <> x, "y=" <> y] = String.split(coord_string, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end

  def distance(ax, ay, bx, by) do
    abs(ax - bx) + abs(ay - by)
  end

  def in_range(%Sensor{x: sx, y: sy, range: range}, x, y) do
    dist = distance(x, y, sx, sy)
    range >= dist
  end

  def check_y_coords(
        %__MODULE__{beacons: beacons, sensors: sensors},
        y_coord,
        minx \\ -1000,
        maxx \\ 1000
      ) do
    minx..maxx
    |> Enum.map(&{&1, y_coord})
    |> Enum.reject(&MapSet.member?(beacons, &1))
    |> Enum.reject(&Map.has_key?(sensors, &1))
    |> Enum.filter(fn {x, y} ->
      Map.values(sensors)
      |> Enum.map(&in_range(&1, x, y))
      |> Enum.any?()
    end)
  end

  def get_sensor_ring(%__MODULE__{sensors: sensors}, low, high) do
    sensors
    |> Map.values()
    |> Enum.flat_map(fn %Sensor{x: x, y: y, range: range} ->
      r = range + 1
      [y1, y2, y3, y4] = [(y + r)..y, y..(y - r), (y - r)..y, y..(y + r)]
      [x1, x2, x3, x4] = [x..(x + r), (x + r)..x, x..(x - r), (x - r)..x]

      Enum.concat([
        Enum.zip(x1, y1),
        Enum.zip(x2, y2),
        Enum.zip(x3, y3),
        Enum.zip(x4, y4)
      ])
    end)
    |> Enum.filter(fn {x, y} ->
      x >= low and x <= high and y >= low and y <= high
    end)
  end

  def find_beacon(
        %__MODULE__{sensors: sensors} = container,
        low \\ 0,
        high \\ 20
      ) do
    get_sensor_ring(container, low, high)
    |> dbg
    |> Stream.reject(fn {x, y} ->
      Map.values(sensors)
      |> Enum.map(&in_range(&1, x, y))
      |> Enum.any?()
    end)
    |> Stream.take(1)
    |> Enum.to_list()
  end
end

defmodule AdventOfCode.Day15 do
  alias __MODULE__.Container

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(Container.new(), &Container.parse_line/2)
    |> Kernel.then(&Container.check_y_coords(&1, 2_000_000, -10_000_000, 10_000_000))
    |> length
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(Container.new(), &Container.parse_line/2)
    |> Kernel.then(&Container.find_beacon(&1, 0, 4_000_000))
    |> Kernel.then(fn [{x, y}] -> x * 4_000_000 + y end)
  end
end
