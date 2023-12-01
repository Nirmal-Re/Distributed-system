defmodule ListModule do
  def sum(numbers) do
    do_sum(numbers, 0)
  end

  def do_sum([], res) do
    res
  end

  def do_sum(numbers, res) do
    [h|t] = numbers
    do_sum(t, res+h)
  end

  def len(numbers) do
    count(numbers, 0)
  end

  def count([], res) do
    res
  end

  def count(numbers, res) do
    [_|t] = numbers
    count(t, res+1)
  end

  def reverse(numbers) do
    do_reverse(numbers, [])
  end

  def do_reverse([], res) do
    res
  end

  def do_reverse([h|t], res) do
    do_reverse(t, [h]++res)
  end

  def non_tail_span(from, to) when from > to do
    []
  end

  def non_tail_span(from, to) when from <= to do
    [from] ++ non_tail_span(from+1, to)
  end

  def tail_span(from, to) do
    do_tail_span(from,to,[])
  end


  def do_tail_span(from, to, res) when from > to do
    res
  end

  def do_tail_span(from, to, res) when from <= to do
    do_tail_span(from+1, to, res ++ [from])
  end

  def square_list(numbers) do
    Enum.map(numbers, fn(x)->x*x end)
  end

  def filter3(numbers) do
    Enum.filter(numbers, fn(x)-> rem(x,3)==0 end)
  end

  def square_and_filter3(numbers) do
    numbers|>square_list|>filter3
  end

  def c_square_list(numbers) do
    for x <- numbers do
      x * x
    end
  end

  def c_filter3(numbers) do
    for x <- numbers, rem(x,3) == 0 do x #comprehension condition can be separated by comma
    end
  end


  def comp_square_and_filter3(numbers) do
    lst = for x <- numbers do
      if rem(x, 3) == 0 do
        x*x
      end
    end
    for n <- lst, n != nil, do: n
  end

  def r_sum(numbers) do
    Enum.reduce(numbers,0, fn(e,sum)-> sum + e end)
  end

  def r_len(numbers) do
    Enum.reduce(numbers,0, fn(e,sum)-> sum + 1 end)
  end

  def r_reverse(numbers) do
    Enum.reduce(numbers,[], fn(e,reverse)-> [e] ++ reverse end)
  end


  def non_tail_flatten([]) do
    []
  end
  def non_tail_flatten([h|t]) do
    if is_list(h) do
      non_tail_flatten(h)++ non_tail_flatten(t)
    else
      [h] ++ non_tail_flatten(t)
    end
  end

  def do_flatten(list) do
    flatten(list, [])
  end

  def flatten([], res) do
    res
  end

  def flatten([h|t], res) do
    if is_list(h) do
      flatten(h ++ t, res)
    else
      flatten(t, res++[h])
    end
  end

end
