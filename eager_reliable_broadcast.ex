#pName is the symbolic name of the process handeling the boradcast(m)
# sn is a sequence number
# sn will be incremented for every newly broadcasted application message but no for echoed message


defmodule EagerReliableBroadcast do
    def start(name, processes, upper_layer_pid) do
        pid = spawn(EagerReliableBroadcast, :init, [name, processes, upper_layer_pid])
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
    def init(name, processes, upper_layer_pid) do
        state = %{
            name: name,
            upper_layer_pid: upper_layer_pid,
            processes: processes,
            delivered: %MapSet{},  # Use this data structure to remember IDs of the delivered messages
            seq_no: 0 # Use this variable to remember the last sequence number used to identify a message
        }
        run(state)
    end

    def run(state) do
        state = receive do
            # Handle the broadcast request event
            {:broadcast, m} ->
                IO.puts("#{inspect state.name}: RB-broadcast: #{inspect m}")
                # Create a unique message identifier from state.name and state.seqno.
                # pid = :global.whereis_name(state.name)
                uid = {state.name, state.seq_no}
                # Create a new data message data_msg from the given payload m
                # the message identifier.
                data_msg = {:data, state.name, state.seq_no, m}
                # Update the state as necessary
                state = %{state | seq_no: state.seq_no + 1}

                # Use the provided beb_broadcast function to propagate data_msg to
                # all process
                # IO.inspect(state)
                # beb_broadcast_with_failures(state.name, :p4, [:p1,:p2,:p3], data_msg, state.processes)
                beb_broadcast(data_msg, state.processes)
                state    # return the updated state

            {:data, proc, seq_no, m} ->
                # IO.inspect(state)
                if MapSet.member?(state.delivered, {proc, seq_no}) do
                    state
                else
                    #TODO: send(:deliver)
                    #TODO: Echo message
                    send(self(), {:deliver, proc, seq_no, m})
                    state = %{state | delivered: MapSet.put(state.delivered, {proc, seq_no})}
                    beb_broadcast({:data, proc, seq_no, m}, state.processes)
                    IO.inspect(state)
                    state
               end

            {:deliver, proc, seq_no, m} ->
                # Simulate the deliver indication event
                # IO.inspect(state)
                IO.puts("#{inspect state.name}: RB-deliver: #{inspect m} from #{inspect proc}")
                send(state.upper_layer_pid, {:deliver, proc, seq_no, m})
                state
        end
        run(state)
    end


    defp unicast({:data, proc, seq_no, m}, p) do
        case :global.whereis_name(p) do
                pid when is_pid(pid) -> send(pid, {:data, proc, seq_no, m})
                :undefined -> :ok
        end
    end

    defp beb_broadcast(m, dest), do: for p <- dest, do: unicast(m, p)

    # You can use this function to simulate a process failure.
    # name: the name of this process
    # proc_to_fail: the name of the failed process (process that will not send to processes present in fail_send_to)
    # fail_send_to: list of processes proc_to_fail will not be broadcasting messages to
    # Note that this list must include proc_to_fail.
    # m and dest are the same as the respective arguments of the normal
    # beb_broadcast.
    defp beb_broadcast_with_failures(name, proc_to_fail, fail_send_to, m, dest) do
        if name == proc_to_fail do
            for p <- dest, p not in fail_send_to, do: unicast(m, p)
        else
            for p <- dest, p != proc_to_fail, do: unicast(m, p)
        end
    end

end
