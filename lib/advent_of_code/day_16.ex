defmodule AdventOfCode.Day16 do
  alias Graph

  def parse_left("Valve " <> rest) do
    [edge, flow] = String.split(rest, " has flow rate=")
    {edge, String.to_integer(flow)}
  end

  def parse_right("tunnel leads to valve " <> vert), do: parse_right_inner(vert)
  def parse_right("tunnels lead to valves " <> verts), do: parse_right_inner(verts)

  def parse_right_inner(verts) do
    verts
    |> String.split(", ", trim: true)
  end

  def parse_line(line, {vertices, edges}) do
    [left, right] = String.split(line, "; ", trim: true)
    {vert, _} = v = parse_left(left)
    edge = {vert, parse_right(right)}
    {[v | vertices], [edge | edges]}
  end

  def add_vertices(graph, []), do: graph

  def add_vertices(graph, [{vert, flow} | tail]) do
    Graph.add_vertex(graph, vert, flow)
    |> add_vertices(tail)
  end

  def add_edges(graph, []), do: graph

  def add_edges(graph, [{vert, to_verts} | tail]) do
    to_verts
    |> Enum.reduce(graph, fn to_vert, graph ->
      Graph.add_edge(graph, vert, to_vert)
    end)
    |> add_edges(tail)
  end

  def add_edges(graph, [{vert, to_vert, weight} | tail]) do
    Graph.add_edge(graph, vert, to_vert, weight: weight)
    |> add_edges(tail)
  end

  def has_flowrate?({_, 0}), do: false
  def has_flowrate?(_), do: true

  def make_interesting_edges(interesting_verts, plain_graph) do
    for {from, _} <- interesting_verts, {to, _} <- interesting_verts, from != to and to != "AA" do
      {from, to}
    end
    |> Enum.map(fn {from, to} ->
      {from, to, (Graph.dijkstra(plain_graph, from, to) |> length) - 1}
    end)
  end

  def lets_go(graph, edge, opened, relief, minutes) do
    new_edges =
      Graph.out_edges(graph, edge)
      |> Enum.reject(fn %{v2: e, weight: weight} ->
        MapSet.member?(opened, e) or weight + 1 >= minutes
      end)

    if new_edges == [] do
      relief
    else
      new_edges
      |> Enum.map(fn %{v2: e, weight: weight} ->
        next_minutes = minutes - weight - 1
        [flow_rate] = Graph.vertex_labels(graph, e)
        next_relief = relief + flow_rate * next_minutes
        lets_go(graph, e, MapSet.put(opened, e), next_relief, next_minutes)
      end)
      |> Enum.max()
    end
  end

  def same_target?(%{v2: e}, %{v2: e}), do: true
  def same_target?(_, _), do: false

  def lets_go2(graph, {me, elephant}, opened, relief, {me_minutes, elephant_minutes}) do
    me_edges =
      Graph.out_edges(graph, me)
      |> Enum.reject(fn %{v2: e, weight: weight} ->
        MapSet.member?(opened, e) or weight + 1 >= me_minutes
      end)

    elephant_edges =
      Graph.out_edges(graph, elephant)
      |> Enum.reject(fn %{v2: e, weight: weight} ->
        MapSet.member?(opened, e) or weight + 1 >= elephant_minutes
      end)

    edge_pairs =
      cond do
        length(me_edges) == 0 && length(elephant_edges) == 0 ->
          []

        length(elephant_edges) == 0 ->
          for me <- me_edges do
            {me, nil}
          end

        length(me_edges) == 0 ->
          for elephant <- elephant_edges do
            {nil, elephant}
          end

        length(me_edges) == 1 and length(elephant_edges) == 1 ->
          [me_edge] = me_edges
          [elephant_edge] = elephant_edges

          if same_target?(me_edge, elephant_edge) do
            if me_edge.weight <= elephant_edges do
              [{me_edge, nil}]
            else
              [{nil, elephant_edge}]
            end
          else
            [{me_edge, elephant_edge}]
          end

        true ->
          for me <- me_edges,
              elephant <- elephant_edges,
              not same_target?(me, elephant) and me != elephant do
            {me, elephant}
          end
      end

    if edge_pairs == [] do
      relief
    else
      edge_pairs
      |> Enum.map(fn
        {%{v2: e, weight: weight}, nil} ->
          next_minutes = me_minutes - weight - 1
          [flow_rate] = Graph.vertex_labels(graph, e)

          added_relief = flow_rate * next_minutes
          next_relief = relief + added_relief

          if me_minutes > 20 && added_relief < 200 do
            next_relief
          else
            lets_go2(
              graph,
              {e, elephant},
              MapSet.put(opened, e),
              next_relief,
              {next_minutes, elephant_minutes}
            )
          end

        {nil, %{v2: e, weight: weight}} ->
          next_minutes = elephant_minutes - weight - 1
          [flow_rate] = Graph.vertex_labels(graph, e)
          added_relief = flow_rate * next_minutes
          next_relief = relief + added_relief

          if elephant_minutes > 20 && added_relief < 200 do
            next_relief
          else
            lets_go2(
              graph,
              {me, e},
              MapSet.put(opened, e),
              next_relief,
              {me_minutes, next_minutes}
            )
          end

        {%{v2: e_me, weight: w_me}, %{v2: e_elephant, weight: w_elephant}} ->
          me_next_minutes = me_minutes - w_me - 1
          elephant_next_minutes = elephant_minutes - w_elephant - 1

          [me_flow_rate] = Graph.vertex_labels(graph, e_me)
          [elephant_flow_rate] = Graph.vertex_labels(graph, e_elephant)

          me_relief = me_flow_rate * me_next_minutes
          elephant_relief = elephant_flow_rate * elephant_next_minutes

          next_relief = relief + me_relief + elephant_relief

          if (me_minutes > 20 and me_relief < 200) or
               (elephant_minutes > 20 and elephant_relief < 200) do
            next_relief
          else
            lets_go2(
              graph,
              {e_me, e_elephant},
              MapSet.put(opened, e_me) |> MapSet.put(e_elephant),
              next_relief,
              {me_next_minutes, elephant_next_minutes}
            )
          end
      end)
      |> Enum.max()
    end
  end

  def part1(args) do
    {vertices, edges} =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce({[], []}, &parse_line/2)

    plain_graph =
      Graph.new()
      |> add_vertices(vertices)
      |> add_edges(edges)

    interesting_verts =
      vertices
      |> Enum.filter(&has_flowrate?/1)
      |> Kernel.then(&[{"AA", 0} | &1])

    interesting_edges = make_interesting_edges(interesting_verts, plain_graph)

    full_graph =
      Graph.new()
      |> add_vertices(interesting_verts)
      |> add_edges(interesting_edges)

    lets_go(full_graph, "AA", MapSet.new(), 0, 30)
  end

  def part2(args) do
    {vertices, edges} =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce({[], []}, &parse_line/2)

    plain_graph =
      Graph.new()
      |> add_vertices(vertices)
      |> add_edges(edges)

    interesting_verts =
      vertices
      |> Enum.filter(&has_flowrate?/1)
      |> Kernel.then(&[{"AA", 0} | &1])

    interesting_edges = make_interesting_edges(interesting_verts, plain_graph)

    full_graph =
      Graph.new()
      |> add_vertices(interesting_verts)
      |> add_edges(interesting_edges)

    lets_go2(full_graph, {"AA", "AA"}, MapSet.new(), 0, {26, 26})
  end
end
