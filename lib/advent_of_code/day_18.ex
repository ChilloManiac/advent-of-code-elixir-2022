defmodule AdventOfCode.Day18.Blob do
  defstruct ~w(voxels)a

  def new do
    %__MODULE__{
      voxels: MapSet.new()
    }
  end

  def add_line(line, %__MODULE__{} = blob) do
    [x, y, z] = String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)

    Map.update!(blob, :voxels, &MapSet.put(&1, {x, y, z}))
  end

  def surface_area(%__MODULE__{voxels: voxels}), do: surface_area(voxels)
  def surface_area(map) do
    map
    |> MapSet.to_list()
    |> Enum.flat_map(&neighbour_coords/1)
    |> Enum.map(fn coord ->
      if MapSet.member?(map, coord) do
        0
      else
        1
      end
    end)
    |> Enum.sum()
  end

  def neighbour_coords({x, y, z}) do
    [{x - 1, y, z}, {x + 1, y, z}, {x, y + 1, z}, {x, y - 1, z}, {x, y, z + 1}, {x, y, z - 1}]
  end

  def surface_area_exterior(%__MODULE__{voxels: voxels}) do
    with_blob = 
      fill_box(voxels, -3, 25)
      |> Kernel.then(&surface_area/1)

    empty_box = 
      fill_box(MapSet.new, -3, 25)
      |> Kernel.then(&surface_area/1)

    with_blob - empty_box
  end

  def fill_box(occupied, low, high) do
    start_coord = {low, low, low}   
    inner_fill_box(occupied, low, high, [start_coord], MapSet.new)
  end

  defp inner_fill_box(_, _, _, [], steam), do: steam
  defp inner_fill_box(occupied, low, high, [next | tail], steam) do
    if MapSet.member?(occupied, next) or MapSet.member?(occupied, steam) do
      dbg()
      inner_fill_box(occupied, low, high, tail, steam) 
    else
      nbs = 
        neighbour_coords(next) 
        |> Enum.reject(fn coord -> Tuple.to_list(coord) |> Enum.any?(& &1 < low) end)
        |> Enum.reject(fn coord -> Tuple.to_list(coord) |> Enum.any?(& &1 >= high) end)
        |> Enum.reject(fn coord -> MapSet.member?(steam, coord) end)
        |> Enum.reject(fn coord -> MapSet.member?(occupied, coord) end)
      
      steam = MapSet.put(steam, next)
      inner_fill_box(occupied, low, high, nbs ++ tail, steam)
    end
  end

  # def get_exterior_values(coords, blob_voxels),
  #   do: get_exterior_values(coords, blob_voxels, Map.new(), 0)
  #
  # def get_exterior_values([], _, _, acc), do: acc
  #
  # def get_exterior_values([c | cs], blob_voxels, air_voxels, acc) do
  #   if MapSet.member?(blob_voxels, c) do
  #     get_exterior_values(cs, blob_voxels, air_voxels, acc)
  #   else
  #     case Map.get(air_voxels, c, :unknown) do
  #       :inside ->
  #         get_exterior_values(cs, blob_voxels, air_voxels, acc)
  #
  #       :outside ->
  #         get_exterior_values(cs, blob_voxels, air_voxels, acc + 1)
  #
  #       :unknown ->
  #         nbs = neighbour_coords(c)
  #         {verdict, checked} = get_n_neighbours(nbs, [], MapSet.new, blob_voxels, air_voxels, 10)
  #        
  #         air_voxels = 
  #           checked
  #           |> Enum.reduce(air_voxels, fn coord, av -> Map.put(av, coord, verdict) end)
  #
  #         to_add = case verdict do
  #           :inside -> 0
  #           :outside -> 1
  #         end
  #
  #         get_exterior_values(cs, blob_voxels, air_voxels, acc + to_add)
  #     end
  #   end
  # end
  #
  # def get_n_neighbours([], [], checked, _, _, _), do: {:inside, MapSet.to_list(checked)}
  # def get_n_neighbours(_, _, checked, _, _, 0), do: {:outside, MapSet.to_list(checked)}
  #
  # def get_n_neighbours([], next_iter, checked, blob_voxels, air_voxels, n),
  #   do: get_n_neighbours(next_iter, [], checked, blob_voxels, air_voxels, n - 1)
  #
  # def get_n_neighbours([next | rest], next_iter, checked, blob_voxels, air_voxels, n) do
  #   if MapSet.member?(blob_voxels, next) or MapSet.member?(checked, next) do
  #     get_n_neighbours(rest, next_iter, checked, blob_voxels, air_voxels, n)
  #   else 
  #     case Map.get(air_voxels, next, :unknown) do
  #       :inside -> {:inside, [next | MapSet.to_list(checked)]}
  #       :outside -> {:outside, [next | MapSet.to_list(checked)]}
  #       :unknown -> 
  #         nbs = neighbour_coords(next)
  #         get_n_neighbours(rest, nbs ++ next_iter, MapSet.put(checked, next), blob_voxels, air_voxels, n)
  #     end
  #   end
  # end
  #
  # When an empty spot is found
  # Find all neighbour
  # For every empty spot repeat x times
  # If we still have spots to search, mark all these as outside
  # Otherwise mark them all as inside
  # Repeat
end

defmodule AdventOfCode.Day18 do
  alias AdventOfCode.Day18.Blob

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(Blob.new(), &Blob.add_line/2)
    |> Kernel.then(&Blob.surface_area/1)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(Blob.new(), &Blob.add_line/2)
    |> Kernel.then(&Blob.surface_area_exterior/1)
  end
end
