#pName is the symbolic name of the process handeling the boradcast(m)
# sn is a sequence number
# sn will be incremented for every newly broadcasted application message but no for echoed message


defmodule EagerReliableBroadcast do
    def start(name, processes) do
        pid = spawn(EagerReliableBroadcast, :init, [name, processes])
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
            maxSNp: %{},
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
                IO.puts("At :data receiver")
                # IO.inspect(state)
                if MapSet.member?(state.delivered, {proc, seq_no}) or Map.has_key?(state.maxSNp, proc) and seq_no <= state.maxSNp[proc] do
                    state
                else
                 # Otherwise, update delivered, generate a deliver event for the
                #upper layer, and re-broadcast (echo) the received message.
                    # state = %{state | delivered: MapSet.put(state.delivered, {proc, seq_no})}
                    #if a message comes through and its sequence number is 0, then create a new entry on state.maxSNp
                    state = cond do
                        seq_no == 0 -> #could use OR here with the second condition
                            state = put_in(state.maxSNp[proc], seq_no)
                            # IO.puts("when sq == 0")
                            # IO.inspect(state)
                            state
                        Map.has_key?(state.maxSNp, proc) and (seq_no-state.maxSNp[proc]) == 1 ->
                            # state = put_in(state.maxSNp[proc], seq_no)
                            state = %{state | maxSNp: Map.put(state.maxSNp, proc, seq_no)}
                            #delete everything else from delivered set till it reaches the latest delivered
                            Enum.each(MapSet.to_list(state.delivered), fn({p, sn}) ->
                                if p == proc and sn == state.maxSNp[proc]+1 do
                                    state = %{state | maxSNp: Map.put(state.maxSNp, proc, seq_no)}
                                    state = %{state | delivered: MapSet.delete(state.delivered, {p, sn})}
                                end
                            end)
                            state
                        true ->
                            %{state | delivered: MapSet.put(state.delivered, {proc, seq_no})}
                    end
                    #if a message comes through and its sequence number isn't 0 and its entry doesn't exist on the
                    #state don't do anything
                    #if a message comes through
                    send(self(), {:deliver, proc, m})
                    state
               end

            {:deliver, proc, m} ->
                # Simulate the deliver indication event
                IO.puts("#{inspect state.name}: RB-deliver: #{inspect m} from #{inspect proc}")
                IO.inspect(state)
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
