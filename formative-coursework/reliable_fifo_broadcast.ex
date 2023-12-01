defmodule ReliableFIFOBroadcast do
    def start(name, processes, client \\ :none) do
        pid = spawn(ReliableFIFOBroadcast, :init, [name, processes, client])
        case :global.re_register_name(name, pid) do
            :yes -> pid
            :no  -> :error
        end
        IO.puts "registered #{name}"
        pid
    end

    # Init event must be the first
    # one after the component is created
    def init(name, processes, client) do
        start_beb(name)
        state = %{
            name: name,
            client: (if is_pid(client), do: client, else: self()),
            processes: processes,
            maxSNp: %{},
            # Add state components below as necessary
            pending: MapSet.new(),
            pendingSeqNo: MapSet.new(),
            seq_no: 0 # Use this variable to remember the last sequence number used to identify a message

            # Next => I don't understand this concept yet.
        }
        run(state)
    end

    # Helper functions: DO NOT REMOVE OR MODIFY
    defp get_beb_name() do
        {:registered_name, parent} = Process.info(self(), :registered_name)
        String.to_atom(Atom.to_string(parent) <> "_beb")
    end

    defp start_beb(name) do
        Process.register(self(), name) #registers self under the name provided
        pid = spawn(BestEffortBroadcast, :init, []) #Spawn a BESTEFFORTBROADCAST instance, capturing its pid
        Process.register(pid, get_beb_name()) # pid is registered globally under the key returned from get_beb_name()
        Process.link(pid)
    end

    defp beb_broadcast(m, dest) do
        BestEffortBroadcast.beb_broadcast(Process.whereis(get_beb_name()), m, dest)
    end

    # End of helper functions

    def run(state) do
        state = receive do
            {:broadcast, m} ->
                # add code to handle client broadcast requests
                # uid = {state.name, state.seq_no}
                data_msg = {:data, state.name, state.seq_no, m}
                state = %{state | seq_no: state.seq_no + 1}
                beb_broadcast(data_msg, state.processes)
                state
            # Add further message handlers as necessary

            # Message handle for delivery event if started without the client argument
            # (i.e., this process is the default client); optional, but useful for debugging
            {:data, proc, seq_no, m} ->
                if MapSet.member?(state.pending, {proc, seq_no, m}) or Map.has_key?(state.maxSNp, proc) and seq_no <= state.maxSNp[proc] do
                    state
                else
                    beb_broadcast({:data, proc, seq_no, m}, state.processes)
                    state = cond do
                        seq_no == 0 -> #could use OR here with the second condition
                            state = put_in(state.maxSNp[proc], seq_no)
                            # state = Map.put(state.pending, proc, %{})
                            # send(state.upper_layer_pid, {:deliver, proc, m})
                            send(self(), {:deliver, self(), proc, m})
                            state
                        Map.has_key?(state.maxSNp, proc) and (seq_no - state.maxSNp[proc]) == 1 ->
                            # state = put_in(state.maxSNp[proc], seq_no)
                            # send(state.upper_layer_pid, {:deliver, proc, m})
                            send(self(), {:deliver, self(), proc, m})
                            state = %{state | maxSNp: Map.put(state.maxSNp, proc, seq_no)}
                            #delete everything else from pending set till it reaches the latest pending
                            #check if the num
                            currentMaxSNp = state.maxSNp[proc]
                            newMaxSNp = count_pending_seq_no(state.pendingSeqNo[proc], currentMaxSNp+1)

                            state = for sn <- currentMaxSNp+1...newMaxSNp, do:
                                state =
                            state = Enum.reduce(MapSet.to_list(state.pending), state, fn({p, sn, p_m}, state) ->
                                if (MapSet.member?(state.pending, {proc, state.maxSNp[proc]+1, p_m})) do
                                    new_maxSNp = state.maxSNp[proc] + 1
                                    state = %{state | maxSNp: Map.put(state.maxSNp, proc, new_maxSNp)}
                                    state = %{state | pending: MapSet.delete(state.pending, {proc, new_maxSNp, p_m})}
                                    send(self(), {:deliver, self(), proc, p_m})
                                    state
                                else
                                    state
                                end
                            end)
                            state
                        true ->
                            Map.put()
                             %{state | pending: MapSet.put(state.pending, {proc, seq_no, m})}
                             state = put_in(state.pending_seq_no[proc], seq_no)
                    end
                    state
               end

            {:deliver, pid, proc, m} ->
                IO.puts("#{inspect state.name}, #{inspect pid}: RFIFO-deliver: #{inspect m} from #{inspect proc}")
                send(state.client, {:deliver, pid, proc, m})
                state
        end
        run(state)
    end

    # Add auxiliary functions as necessary
    defp count_pending_seq_no(pendingSeqNo, nextMaxSNp){
        if (MapSet.member?(pendingSeqNo, nextMaxSNp)) do
            count_pending_seq_no(pendingSeqNo, nextMaxSNp + 1)
        else
            nextMaxSNp-1;
        end
    }

end
