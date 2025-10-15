defmodule MathFunction do
  def add_terms(term) do
    terms = String.split(term, ["+", "-"])
    operation_list = Enum.map(String.codepoints(term), fn(val) -> op_helper(val) end)
      |> Enum.filter(fn(val) -> val == "+" or val == "-" end)
    operation_list = ["+" | operation_list]
    ret_maps = Enum.map(terms, fn(val) -> create_maps_helper(val, String.contains?(val, "x"), String.contains?(val, "^"), String.first(val) === "x") end)
    final_map = Enum.zip_with(ret_maps, operation_list, fn(val, op) -> final_helper(val, op) end)
    final_map

    #IO.inspect(final_map)
  end

  defp op_helper("+") do
    "+"
  end

  defp op_helper("-") do
    "-"
  end

  defp op_helper(_val) do
    ""
  end

#This is the case when the expontent is 2 or gereater and the coeficcient is 1
  defp create_maps_helper(number, true, true, true) do
    temp_list = String.split(number, "x^")
    ret_map = %{coefficient: 1, exponent: String.to_integer(List.last(temp_list))}
    ret_map
  end

#This is the case when the exponent is 1 and the coeficcient is 1
  defp create_maps_helper(_number, true, false, true) do
    ret_map = %{coefficient: 1, exponent: 1}
    ret_map
  end


#This is the case when the exoponent is 2 or greater (and the coefficient is not 1)
  defp create_maps_helper(number, true, true, false) do
    temp_list = String.split(number, "x^")
    ret_map = %{coefficient: String.to_integer(List.first(temp_list)), exponent: String.to_integer(List.last(temp_list))}
    ret_map
  end


#This is th case when the exponent is one (and the coefficient is not 1)
  defp create_maps_helper(number, true, false, false) do
    ret_map = %{coefficient: String.to_integer(String.first(number)), exponent:  1}
    ret_map
  end


#This is the case when the exponent in zero (number * x^0)
  defp create_maps_helper(number, false, false, false) do
    ret_map = %{:coefficient => String.to_integer(number), :exponent => 0}
    ret_map
  end

  defp final_helper(map, op) when op === "+" do
    map
  end

  defp final_helper(map, op) when op === "-" do
    Map.put(map, :coefficient, Map.get(map, :coefficient) * -1)
  end

  defp eval_at_x(_int, [], value) do
    value * 1.0
  end

  defp eval_at_x(int, [head | tail], value) do
    val = int * 1.0
    ret_val = Float.pow(val, head[:exponent])
    ret_val = ret_val * head[:coefficient]
    value = value + ret_val
    eval_at_x(int, tail, value)
  end



  def eval_terms(int, terms) do
    num = eval_at_x(int, terms, 0.0)
    num
  end
end


#map_list = MathFunction.add_terms("x^2+3x+4")
#MathFunction.eval_terms(3, map_list)

defmodule Integral do
  def eval_integral_record_times(func, num, start_range, end_range, delta) do
    {_duration, results} = :timer.tc(Integral, :evaluate, [func, start_range, end_range, delta, num])

    #IO.puts("#{duration / 1000000} seconds")

    results
  end

  def evaluate(math_func, start_x, end_x, delta, num_processes) do

    chunk_sizes = get_span_size((end_x - start_x), num_processes / 1.0)

    Enum.each(0..num_processes - 1, fn(proc_index) ->
      proc_start = start_x + (proc_index * chunk_sizes)
      proc_end = get_end_range((proc_start + chunk_sizes - delta), end_x)

      spawn_link(Integral, :eval_integral_with_process, [self(), proc_start, proc_end, math_func, delta])
    end)

    await_results(num_processes, 0)

    #ret_val = eval_helper(math_func, start_x, end_x, delta, 0.0)
    #ret_val

  end

  defp get_end_range(proposed_end, end_x) when proposed_end <= end_x do
    proposed_end
  end

  defp get_end_range(_proposed_end, end_x) do
    end_x
  end

  defp get_span_size(length, num_of_processes) do
    ret_val = length / num_of_processes
    ret_val
  end

  # defp get_span_size(length, num_of_processes) do
  #   ret_val = (length / num_of_processes) + 1
  #   ret_val
  # end

  def eval_integral_with_process(server_pid, proc_start, proc_end, func, delta) do
    #IO.puts(proc_start)
    #IO.puts(proc_end)
    send(server_pid, {:integral, eval_helper(func, proc_start, proc_end, delta, 0)})
  end

  def eval_helper(func, curr_x, end_x, delta, value) when curr_x >= end_x do
    num = MathFunction.eval_terms(curr_x, func)
    value = value + num
    value = value * delta
    value
  end

  def eval_helper(func, curr_x, end_x, delta, value) do
    num = MathFunction.eval_terms(curr_x, func)
    value = value + num
    eval_helper(func, curr_x + delta, end_x, delta, value)
  end

  def to_s(func, start_x, end_x, delta) do
    function = Enum.map(func, fn(val) -> reconstruct_term(val) end)
      |> Enum.join()
      |> String.replace_prefix("+", "")

    ret_string = "Area under the curve of " <> function <> " from " <> Float.to_string(start_x) <> " to " <> Float.to_string(end_x) <> ": " <> Float.to_string(eval_integral_record_times(func, System.schedulers_online(), start_x, end_x, delta))
    ret_string
  end

  defp await_results(0, results) do
    results
  end


  defp await_results(num_processes, results) do
    receive do
      {:integral, value} -> await_results(num_processes - 1, results + value)
    end
  end

  defp reconstruct_term(term) do
    term_helper(term[:coefficient], term[:exponent], term[:coefficient] === 1 or term[:coefficient] === -1, term[:coefficient] > 0, term[:exponent] === 1, term[:exponent] === 0)
  end


  #The coefficient is 1, and the exponent is one
  defp term_helper(_coef, _exp, true, true, true, false) do
    "+x"
  end


  #The coefficient is -1, and the exponent is one
  defp term_helper(_coef, _exp, true, false, true, false) do
    "-x"
  end

  #The coefficient is -1, and the exponent is 0
  defp term_helper(coef, _exp, true, false, false, true) do
    Integer.to_string(coef)
  end


  #The coefficient is 1, and the exponent is 0
  defp term_helper(coef, _exp, true, true, false, true) do
    "+" <> Integer.to_string(coef)
  end

  #The coefficient is greater than 1, and the exponent is 0
  defp term_helper(coef, _exp, false, true, false, true) do
    "+" <> Integer.to_string(coef)
  end

  #The coefficient is greater than 1, and the exponent is 1
  defp term_helper(coef, _exp, false, true, true, false) do
    "+" <> Integer.to_string(coef) <> "x"
  end

  #The coefficient is negative one, but the exponent is greater than 1
  defp term_helper(_coef, exp, true, false, false, false) do
    "-x^" <> Integer.to_string(exp)
  end

  #The coefficient is one, but exponent is greater than 1
  defp term_helper(_coef, exp, true, true, false, false) do
    "+x^" <> Integer.to_string(exp)
  end

  #THe coefficient is less than -1, and the exponent is 1
  defp term_helper(coef, _exp, false, false, true, false) do
    Integer.to_string(coef) <> "x"
  end

  #The coefficient is less than -1, and the exponent is 0
  defp term_helper(coef, _exp, false, false, false, true) do
    Integer.to_string(coef)
  end

  #The coefficient is less than -1, and the exponent is greater than 1
  defp term_helper(coef, exp, false, false, false, false) do
    Integer.to_string(coef) <> "x^" <> Integer.to_string(exp)
  end


  #The coefficent is greater than 1, the expontent is greater than 1
  defp term_helper(coef, exp, false, true, false, false) do
    "+" <> Integer.to_string(coef) <> "x^" <> Integer.to_string(exp)
  end





end

math_func = MathFunction.add_terms("x^2+3x+1")

#IO.puts(Integral.to_s(math_func, 1.0, 2.0, 0.001))
#IO.inspect(Integral.eval_integral_record_times(math_func, System.schedulers_online(), 1.0, 2.0, 0.001))
IO.puts(Integral.to_s(math_func, 1.0, 2.0, 0.001))
