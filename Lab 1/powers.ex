defmodule Powers  do
  def square(n) do
    n * n
  end

  def cube(n) do
    square(n) * n
  end


  def square_or_cube(n, p) when p == 2 do
    square(n)
  end

  def square_or_cube(n, 3) do
    cube(n)
  end

  def square_or_cube(_, _) do
    "I don't know how to do that"
  end

  def pow(n, 0) do
    1
  end

   def pow(n, p) when p> 0 and is_integer(p) do
    n * pow(n, p-1)
  end

  def pow(n,p) when p<0 and is_integer(p) do
    p = abs(p)
    1 / pow(n, p)
  end

  def pow(_, _) do
    {:error, "negative exponent"}
  end



end
