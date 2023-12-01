defmodule FrequencyTable do
  def update_freq(k, map) do
    cond do
      Map.has_key?(map,k) ->
        Map.put(map, k, map[k]+1)
      true ->
        Map.put(map, k, 1)
    end
  end

  def do_freq_count_body(list) do
    freq_count_body(list, %{})
  end

  def freq_count_body([], map) do
    map
  end
  def freq_count_body([h|tail], map) do
    freq_count_body(tail, update_freq(h, map))
  end

  #word count
  def word_count(words) do
    do_freq_count_body(Enum.map(String.split(words,~r{,},trim: true), fn x -> String.downcase(x) end))
  end


  def swap_map(map) do
    for {key, value} <- map, do: {key, value}
  end

  def _histogram(dict) do
    # total = Enum.reduce(dict, 0, fn({_, v}, y) -> v + y end)
    all_values = for {_, value} <- map, do: value
    total = Enum.sum(all_values)
    per_words = for {key, value} <- map, do: {trunc((value/total)*100), key}
    Enum.sort(per_words, fn({per, word}, {per2, word2}) -> per > per2 end)
  end

end
