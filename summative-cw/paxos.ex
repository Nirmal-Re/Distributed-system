defmodule Paxos do
  @doc """
  name = name of this paxos process
  participants = name of participants taking part in this consensus
  """

  def start(name, participants) do
    # 1. spawns a paxos process,
    # 2. registers it in the global registry under the name,
    # 3. returns pid of process that was just spawned

    # ???The argument participants must be assumed to include symbolic names of all replicas (including the one specified by name) participating in the protocol ????
  end

  @doc """
  pid: pid of an an elixir process running a paxos replica
  inst: an instance identifier
  value: propose a value for the instance of consensus associated with inst
  t: a timeout in milliseconds
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
