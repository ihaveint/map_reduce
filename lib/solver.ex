defmodule Solver do
  use GenServer
  require Mapper

  def init(_args) do
    {:ok, %{elements: [], map: [], reduce: []}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_element, element}, state) do
    {:noreply, %{state | elements: [element | state.elements]}}
  end

  # old : :set_raw_array
  def handle_cast({:set_elements, elements}, state) do
    {:noreply, %{state | elements: elements}}
  end

  def handle_cast({:calc, pid}, state) do
    solve(state.map, state.elements, state.reduce, pid)
    {:noreply, state}
  end

  def handle_cast({:set_map_reduce, map, reduce}, state) do
    {:noreply, %{state | map: map, reduce: reduce}}
  end

  defp solve(map_lambda, raw, reduce_lambda, pid) do
    send(
      pid,
      {:result,
       Mapper.apply_map(map_lambda, raw)
       |> Enum.reduce(fn x, acc -> reduce_lambda.(acc, x) end)}
    )
  end
end
