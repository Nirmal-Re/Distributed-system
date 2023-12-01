defmodule Practice do
  def map_in_a_map(map, [key], value), do: Map.put(map, key, value)

  def map_in_a_map(map, [key | rest], value) do
    Map.put(map, key, map_in_a_map(Map.get(map, key, %{}), rest, value))
  end
end


# %{
#   k1: %{
#     k2: v
#   }
# }
