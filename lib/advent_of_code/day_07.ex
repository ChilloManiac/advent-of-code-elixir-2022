defmodule AdventOfCode.Day07.FileTree do
  defstruct current_dir: nil, files: nil

  def new do
    %__MODULE__{files: {:dir, Map.new()}, current_dir: ""}
  end

  def current_dir_to_list(%__MODULE__{current_dir: current_dir}) do
    current_dir |> String.split("/") |> Enum.drop(1)
  end

  def do_cd(%__MODULE__{current_dir: current_dir} = ft, "..") do
    new_path =
      current_dir
      |> String.split("/")
      |> Enum.drop(-1)
      |> Enum.join("/")

    Map.put(ft, :current_dir, new_path)
  end

  def do_cd(%__MODULE__{} = ft, "/") do
    Map.put(ft, :current_dir, "")
  end

  def do_cd(%__MODULE__{} = ft, path) do
    Map.update!(ft, :current_dir, &(&1 <> "/" <> path))
  end

  def insert_file({:dir, %{} = map}, [], {size, filename}) do
    {:dir, Map.put(map, filename, {:file, String.to_integer(size)})}
  end

  def insert_file({:dir, %{} = map}, [head | tail], file) do
    {:dir, Map.update!(map, head, &insert_file(&1, tail, file))}
  end

  def do_new_file(%__MODULE__{files: files} = ft, new_file) do
    [size, filename] = String.split(new_file, " ")
    paths = current_dir_to_list(ft)
    files = insert_file(files, paths, {size, filename})
    %__MODULE__{ft | files: files}
  end

  def insert_map({:dir, %{} = map}, [], key) do
    {:dir, Map.put(map, key, {:dir, Map.new()})}
  end

  def insert_map({:dir, %{} = map}, [head | tail], key) do
    {:dir, Map.update!(map, head, &insert_map(&1, tail, key))}
  end

  def do_dir(%__MODULE__{files: files} = ft, new_dir) do
    paths = current_dir_to_list(ft)
    files = insert_map(files, paths, new_dir)
    %__MODULE__{ft | files: files}
  end

  def handle_commands(
        chead,
        %__MODULE__{} = ft
      ) do
    case chead do
      "$ cd " <> rest -> do_cd(ft, rest)
      "$ ls" -> ft
      "dir " <> new_dir -> do_dir(ft, new_dir)
      new_file -> do_new_file(ft, new_file)
    end
  end

  def do_to_size({:dir, %{} = map}) do
    children = Map.values(map)

    files = Enum.filter(children, &(elem(&1, 0) == :file))

    dirs = Enum.reject(children, &(elem(&1, 0) == :file))

    file_sizes =
      files
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    dir_sizes =
      dirs
      |> Enum.map(&do_to_size/1)

    this_size = file_sizes + Enum.sum(dir_sizes)

    this_size
  end

  def to_size({:dir, files}) do
    Map.new(files, fn
      {key, {:file, _}} -> {key, :file}
      {key, value} -> {key, {do_to_size(value), to_size(value)}}
    end)
  end

  def to_size(%__MODULE__{files: files}) do
    to_size(files)
  end

  def to_size_list(%{} = map) do
    Map.values(map)
    |> Enum.reject(&(&1 == :file))
    |> Enum.map(fn
      {val, map} -> Enum.concat([[val] | to_size_list(map)])
    end)
  end
end

defmodule AdventOfCode.Day07 do
  alias AdventOfCode.Day07.FileTree

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(FileTree.new(), &FileTree.handle_commands/2)
    |> FileTree.to_size()
    |> FileTree.to_size_list
    |> Enum.concat
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  def part2(args) do
    root = 
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(FileTree.new(), &FileTree.handle_commands/2)

    root_size = FileTree.do_to_size(root.files)
    dbg(root_size)

    to_go = root_size - 40_000_000
    dbg(to_go)

    root
    |> FileTree.to_size()
    |> FileTree.to_size_list
    |> Enum.concat
    |> Enum.filter(& &1 >= to_go)
    |> Enum.sort(:asc)
    |> Enum.at(0)
    |> dbg

  end
end
