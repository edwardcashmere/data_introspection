defmodule DataIntrospectionWeb.PlotsLive.Helper do
  @moduledoc """
  encapsulates the logic for the plots views
  """
  @file_path Application.compile_env(:data_introspection, :file_path)

  @doc """
    parse the csv file
  """
  @spec parse_csv(String.t()) :: {list(String.t()), list(String.t()), list(list(String.t()))}
  def parse_csv(file_path) do
    [headers | rest] =
      File.stream!(file_path)
      |> CSV.decode()
      |> Enum.map(fn {:ok, data} -> data end)

    first_row = List.first(rest)
    {headers, first_row, rest}
  end

  @doc """
    filter expression data
  """
  @spec filter_expression_data(list(String.t()), String.t(), list(list(String.t()))) ::
          list(String.t())
  def filter_expression_data(headers, expression, data) do
    index =
      headers
      |> Enum.map(fn value_string -> value_string |> String.trim() |> String.downcase() end)
      |> Enum.find_index(fn string_term -> string_term == expression end)

    Enum.map(data, fn row -> Enum.at(row, index) end)
  end

  @spec format_dataset(list(), list(String.t()), String.t()) ::
          list()
  def format_dataset(data, headers, expression) do
    updated_expression = expression |> String.trim() |> String.downcase()

    case {String.contains?(updated_expression, "*"), String.contains?(updated_expression, "/"),
          String.contains?(updated_expression, "+"), String.contains?(updated_expression, "-")} do
      {true, _, _, _} ->
        {first_value_index, second_value_index} =
          get_header_index(headers, String.split(expression, "*"))

        data
        |> Enum.map(fn row ->
          {Enum.at(row, first_value_index), Enum.at(row, second_value_index)}
        end)
        |> sanitize_data_and_perform_operation("*")

      {_, true, _, _} ->
        {first_value_index, second_value_index} =
          get_header_index(headers, String.split(expression, "/"))

        data
        |> Enum.map(fn row ->
          {Enum.at(row, first_value_index), Enum.at(row, second_value_index)}
        end)
        |> sanitize_data_and_perform_operation("/")

      {_, _, true, _} ->
        {first_value_index, second_value_index} =
          get_header_index(headers, String.split(expression, "+"))

        data
        |> Enum.map(fn row ->
          {Enum.at(row, first_value_index), Enum.at(row, second_value_index)}
        end)
        |> sanitize_data_and_perform_operation("+")

      {_, _, _, true} ->
        {first_value_index, second_value_index} =
          get_header_index(headers, String.split(expression, "-"))

        data
        |> Enum.map(fn row ->
          {Enum.at(row, first_value_index), Enum.at(row, second_value_index)}
        end)
        |> sanitize_data_and_perform_operation("-")
    end
  end

  @spec get_file_path() :: String.t()
  def get_file_path do
    File.cwd!() <> @file_path
  end

  def get_header_index(headers, [first_expression, second_expression] = _expressions) do
    updated_headers =
      Enum.map(headers, fn value_string -> value_string |> String.trim() |> String.downcase() end)

    first_expression_index =
      Enum.find_index(updated_headers, fn string_term ->
        string_term == String.trim(first_expression)
      end)

    second_expression_index =
      Enum.find_index(updated_headers, fn string_term ->
        string_term == String.trim(second_expression)
      end)

    {first_expression_index, second_expression_index}
  end

  @spec sanitize_data_and_perform_operation(list({String.t(), String.t()}), String.t()) ::
          list()
  # credo:disable-for-next-line Credo.Check.Refactor.ABCSize
  def sanitize_data_and_perform_operation(data, operator) do
    data
    |> Enum.map(fn
      {left, right} when is_binary(left) and is_binary(right) ->
        case {String.contains?(left, "."), String.contains?(right, ".")} do
          {true, true} ->
            {convert_to_float(left), convert_to_float(right)}

          {true, false} ->
            {convert_to_float(left), convert_to_integer(right)}

          {false, true} ->
            {convert_to_integer(left), convert_to_float(right)}

          {false, false} ->
            {convert_to_integer(left), convert_to_integer(right)}
        end

      {left, right} when is_binary(left) ->
        case String.contains?(left, ".") do
          true -> {convert_to_float(left), right}
          false -> {convert_to_integer(left), right}
        end

      {left, right} when is_binary(right) ->
        case String.contains?(right, ".") do
          true -> {left, convert_to_float(right)}
          false -> {left, convert_to_integer(right)}
        end

      {left, right} ->
        {left, right}
    end)
    |> Enum.reduce([], fn {left, right}, acc ->
      [perform_operation({left, right}, operator) | acc]
    end)
  end

  # we set undefined values to 1 instead of 0 to avoid division by zero which an infinity return
  def convert_to_integer(data_point) when is_integer(data_point), do: data_point

  def convert_to_integer(data_point) when is_binary(data_point) do
    String.to_integer(data_point)
  rescue
    _ -> 1
  end

  def convert_to_integer(_data_point), do: 1

  def convert_to_float(data_point) when is_float(data_point), do: data_point

  def convert_to_float(data_point) when is_binary(data_point) do
    String.to_float(data_point)
  rescue
    _ -> 1.1
  end

  def convert_to_float(_data_point), do: 1

  defp perform_operation({_left, 0}, "/"), do: 0
  defp perform_operation({left, right}, "/"), do: left / right
  defp perform_operation({left, right}, "*"), do: left * right
  defp perform_operation({left, right}, "+"), do: left + right
  defp perform_operation({left, right}, "-"), do: left - right
end
