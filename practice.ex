defmodule Practice do
  def map_in_a_map(map, [key], value), do: Map.put(map, key, value)

  def map_in_a_map(map, [key | rest], value) do
    Map.put(map, key, map_in_a_map(Map.get(map, key, %{}), rest, value))
  end


    # Helper functions: DO NOT REMOVE OR MODIFY
  defp get_created_process_name() do
    {:registered_name, parent} = Process.info(self(), :registered_name)
    String.to_atom(Atom.to_string(parent) <> "_beb")
  end

  def create_process(name) do
    Process.register(self(), name)
    pid = spawn(fn -> :ok end)
    Process.register(pid, get_created_process_name())
    Process.link(pid)
  end
end


# %{
#   k1: %{
#     k2: v
#   }
# }
