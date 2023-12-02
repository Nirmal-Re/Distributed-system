defmodule EventualLeaderDetector do
  # To spawn a leader detector
  def start(name, processes) do
    spawn(EventualLeaderDetector, :init, [name, process])
  end

  def init(name, processes) do
    # start increasing timeout
    it = IncreasingTimeout.start(name, processes, self())
    # Linking EvuentualLeaderDetector with Increasing timeout
    # so if one dies the other dies as well
    Process.link(it)

    state = %{
      name: name,
      processes: processes
    }
  end

  # start increasing timeout
  def start_it() do
  end

  def get_it_name() do
    {:registered_name, parent} = Process.info(self(), :registered_name)
    String.to_atom(Atom.to_string(parent) <> "_it")
  end

  defp get_max(alive) do
  end
end
