defmodule DataProcessor do
  @moduledoc """
  Processes and cleans data using Elixir's Enum module.
  """

  @doc """
  Cleans data by removing nils, converting types, and standardizing formats.
  """
  def clean(data) when is_list(data) do
    data
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&standardize_row/1)
  end

  @doc """
  Filters data based on provided conditions.
  Conditions should be a keyword list of field-value pairs.
  """
  def filter(data, conditions) when is_list(data) and is_list(conditions) do
    Enum.filter(data, &matches_conditions?(&1, conditions))
  end

  @doc """
  Transforms data using provided mapping function.
  """
  def transform(data, transform_fn) when is_list(data) and is_function(transform_fn) do
    Enum.map(data, transform_fn)
  end

  @doc """
  Groups data by specified field.
  """
  def group_by(data, field) when is_list(data) do
    Enum.group_by(data, &Map.get(&1, field))
  end

  defp standardize_row(%{} = row) do
    row
    |> Enum.map(fn {k, v} -> {k, standardize_value(v)} end)
    |> Enum.into(%{})
  end

  defp standardize_row(row), do: row

  defp standardize_value(value) when is_binary(value) do
    value |> String.trim() |> String.downcase()
  end
  defp standardize_value(value), do: value

  defp matches_conditions?(row, conditions) do
    Enum.all?(conditions, fn {field, value} ->
      Map.get(row, field) == value
    end)
  end
end
data |> DataProcessor.clean() |> DataProcessor.filter(status: "active")
