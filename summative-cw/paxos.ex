defmodule Paxos do
  @doc """
  name = name of this paxos process
  participants = name of participants taking part in this consensus
  """

  def start(name, participants, client \\ :none)  do
    pid = spawn(Paxos, :init, [name, participants, client]) # Spawns paxos process
    case :global.re_register_name(name, pid) do   # Registers it in the global registry under the name,
      :yes -> pid
      :no -> :error
    end
    IO.puts"Registered Paxos Instance #{name}"
    pid # Returns pid of process that was just spawned

  end

  def init(name, processes, client) do
    Process.register(self(), name) #registers self under the name provided
    start_eld(name, processes)
    start_beb(name)
    state = %{
      name: name,
      leader: name,
      processes: processes,
      client: (if is_pid(client), do: client, else: self()),
      myBallot: nil,
      decided: false,
      bal: nil,
      aBal: nil,
      aVal: nil,
      value: nil,
      delta: 10000,
    }
    run(state)
  end

  # Helper functions: DO NOT REMOVE OR MODIFY
    defp get_child_name(childType) do
      {:registered_name, parent} = Process.info(self(), :registered_name)
      String.to_atom(Atom.to_string(parent) <> childType)
    end

    defp start_beb(name) do
      pid = spawn(BestEffortBroadcast, :init, []) #Spawn a BESTEFFORTBROADCAST instance, capturing its pid
      Process.register(pid, get_child_name("_beb")) # pid is registered globally under the key returned from get_child_name(childType)
      Process.link(pid)
    end

    defp beb_broadcast(m, dest) do
      BestEffortBroadcast.beb_broadcast(Process.whereis(get_child_name("_beb")), m, dest)
    end

    defp start_eld(name, processes) do
      childProcesses = name_all_processes(processes, "_eld")
      pid = spawn(EventualLeaderDetector, :start, [get_child_name("_eld"), childProcesses, self()]) #Spawn a BESTEFFORTBROADCAST instance, capturing its pid TODO: This will require more
      Process.register(pid, get_child_name("_eld")) # pid is registered globally under the key returned from get_child_name(childType)
      Process.link(pid)
    end

    defp name_all_processes(processes, childType) do
      for x <- processes, do: String.to_atom(Atom.to_string(x) <> childType)
    end
  @doc """
  This is the main meat of the paxos. This where everything will happen
  """
  def run(state) do
    state =
      receive do
        {:trust, leaderName} ->
        state = %{state | leader: leaderName}
        IO.puts("New Leader: #{leaderName}")
        # if leaderName == state.name and state.decided == false, do:
      end

    run(state)
  end

  @doc """
  This function is here to send the value to the process that is running the currect concensus (current leader running paxos)
  pid: pid of an an elixir process running a paxos replica (pid of the process that is the current leader i.e the one running paxos)
  inst: an instance identifier (the pid of the currect process)
  value: propose a value to paxos (identified by pid)
  t: a timeout in milliseconds (This must be returned if no decision is made with in the timeout)
  """
  def propose(pid, inst, value, t) do
    #{:decision, v}
    #{abort}
    #{:timeout}
  end

  def get_decision(pid, inst, t) do
    #returns v != nil -- if v is the value decided by the consenssus instance inst; it retuns nill in all other cases
  end


end
