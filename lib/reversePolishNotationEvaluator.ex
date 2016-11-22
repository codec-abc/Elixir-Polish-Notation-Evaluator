defmodule ReversePolishNotationEvaluator do

  require IEx

  @spec main(any) :: :ok
  def main(_) do
    string = IO.gets "Enter polish notation expression :"

    #remove end line for parsing
    string = String.replace string, "\n", ""
    string = String.replace string, "\r", ""

    is_input_parsable = input_parsable?(string)
    case is_input_parsable do
      true ->
        splitted = String.split(string, " ")
        function_and_numbers = Enum.map(splitted, &parse_symbols/1)
        result = Enum.reduce(function_and_numbers, [], &reduce_token/2)
        result_length = length(result)
        case result_length do
          1 -> IO.puts "Result is #{List.first(result)}"
          _ -> IO.puts "Error buffer not containing one element at the end" 
        end
      false ->
        IO.puts "The input cannot be parsed correctly"
    end
  end

  #@spec reduce_token({:ok, ((number, number) -> number) | number}, [number]) :: [number,...]
  @spec reduce_token({:ok, ((any, any) -> any) | number}, [any]) :: [any,...]
  def reduce_token(elem, acc) do
    case elem do
      {:ok, n} when is_number(n) ->
        acc ++ [n]
      {:ok, f} when is_function(f) ->
        y = List.last(acc)
        acc = List.delete_at(acc, length(acc) -1)
        x = List.last(acc)
        acc = List.delete_at(acc, length(acc) -1)
        acc ++ [f.(x, y)]
      end
  end

  @spec token_valid?(String.t) :: boolean
  def token_valid?(token) do
    parsed_result = parse_symbols(token)
    case parsed_result do
      {:ok, _} -> true
      _ -> false
    end
  end

  #@spec input_parsable?(binary) :: boolean
  @spec input_parsable?(binary) :: any #boolean
  def input_parsable?(string) do
    splitted = String.split(string, " ")
    parse_and = fn (elem, acc) ->
      is_token_valid = ReversePolishNotationEvaluator.token_valid?(elem)
      is_token_valid and acc
      end
    Enum.reduce(splitted, true, parse_and)
  end

  @spec parse_symbols(String.t) :: {:ok, (number, number -> number)} | {:ok, number} | {:error, String.t}
  def parse_symbols(string) do
    case string do
      "*" -> {:ok, fn (x, y) -> x * y end}
      "+" -> {:ok, fn (x, y) -> x + y end}
      "-" -> {:ok, fn (x, y) -> x - y end}
      "/" -> {:ok, fn (x, y) -> x / y end}
      _ -> try_parse_number(string)
    end
  end

  @spec try_parse_number(String.t) :: {:ok, number} | {:error, String.t}
  def try_parse_number (string) do
    try_parse = Float.parse(string)
    case try_parse do
      :error -> {:error, "Cannot parse #{string} as a number"}
      {float, _} -> {:ok, float}
    end
  end

end
