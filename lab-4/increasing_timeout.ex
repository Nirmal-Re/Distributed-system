defmodule IncreasingTimeout do
  @delta 1000
  @delay 5000

  def start(name, processes) do
      pid = spawn(IncreasingTimeout, :init, [ name, processes])
      # :global.unregister_name(name)
      case :global.re_register_name(name, pid) do
          :yes -> pid
          :no  -> :error
      end
      IO.puts "registered #{name}"
      pid
  end

  # Init event must be the first
  # one after the component is created
  def init(name, processes) do
      state = %{
          name: name,
          processes: processes,
          delta: 10000, # timeout in millis
          alive: MapSet.new(processes),
          suspected: MapSet.new()
      }
      Process.send_after(self(), {:timeout}, state.delta)
      run(state)
  end

  def run(state) do
      state = receive do
          {:timeout} ->
              IO.puts("#{state.name}: #{inspect({:timeout})}")
              state = adjust_delta(state)
              state = check_and_probe(state, state.processes)
              state = %{state | alive: %MapSet{}}
              Process.send_after(self(), {:timeout}, state.delta)
              state

          {:heartbeat_request, pid} ->
              IO.puts("#{state.name}: #{inspect({:heartbeat_request, pid})}")
              if state.name == :p1, do: Process.sleep(@delay)
              send(pid, {:heartbeat_reply, state.name})
              state

          {:heartbeat_reply, name} ->
              IO.puts("#{state.name}: #{inspect {:heartbeat_reply, name}}")

              %{state | alive: MapSet.put(state.alive, name)} #state.alive is wiped clean after check_and_probe function is called. But here it is filled back up again

          {:crash, p} ->
              IO.puts("#{state.name}: CRASH detected #{p}")
              state

          {:sus, p} ->
            IO.puts("#{state.name}: SUS detected #{p}")
            state
      end
      run(state)
  end

  defp adjust_delta(state) do
    state = %{state | delta: (state.delta + calculate_delta_difference(state))}
    IO.puts(state.delta)
    state
  end

  defp calculate_delta_difference(state) do
    disjoint = MapSet.disjoint?(state.alive, state.suspected)
    IO.inspect(state.suspected)
    if disjoint, do: 0, else: @delta
  end

  defp check_and_probe(state, []), do: state
  defp check_and_probe(state, [p | p_tail]) do
      state = cond do
        p not in state.alive and p not in state.suspected and :global.whereis_name(p) !=self() ->
          state = %{state | suspected: MapSet.put(state.suspected, p)}
          send(self(), {:sus, p})
          state
        p in state.alive and p in state.suspected and :global.whereis_name(p) !=self() ->
          state = %{state |suspected: MapSet.delete(state.suspected, p)}
          send(self(), {:restored, p})
          state
        true ->
          state
      end
      case :global.whereis_name(p) do
          pid when is_pid(pid) and pid !=self() -> send(pid, {:heartbeat_request, self()})
          pid when is_pid(pid) -> :ok
          :undefined -> :ok
      end
      check_and_probe(state, p_tail)
  end
end

#procs = [:p1, :p2, :p3]
#pids = Enum.map(procs, fn p -> IncreasingTimeout.start(p, procs) end)
