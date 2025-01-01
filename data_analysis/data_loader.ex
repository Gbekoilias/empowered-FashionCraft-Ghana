defmodule DataLoader do
  @moduledoc """
  Module for loading data from CSV files and database sources.
  Provides flexible data fetching and parsing capabilities.
  """

  alias NimbleCSV.RFC4180, as: CSV
  require Logger

  @doc """
  Loads data from either a CSV file or database based on the provided path/config.
  Returns {:ok, data} on success or {:error, reason} on failure.
  """
  def load(source) when is_binary(source) do
    cond do
      String.ends_with?(source, ".csv") -> load_csv(source)
      true -> {:error, "Unsupported file format"}
    end
  end

  def load(%{type: :database} = config) do
    load_from_database(config)
  end

  @doc """
  Loads and parses data from a CSV file.
  """
  def load_csv(data_path) do
    try do
      parsed_data =
        data_path
        |> File.stream!()
        |> CSV.parse_stream()
        |> Stream.map(&process_row/1)
        |> Enum.to_list()

      {:ok, parsed_data}
    rescue
      e in File.Error ->
        Logger.error("Failed to read CSV: #{inspect(e)}")
        {:error, "Failed to read CSV file"}

      e ->
        Logger.error("Unexpected error: #{inspect(e)}")
        {:error, "Failed to parse data"}
    end
  end

  @doc """
  Loads data from database using Ecto.
  Expects config map with :repo, :schema, and optional :query keys.
  """
  def load_from_database(%{repo: repo, schema: schema} = config) do
    try do
      query = config[:query] || schema

      data =
        repo.all(query)
        |> Enum.map(&process_database_row/1)

      {:ok, data}
    rescue
      e in Ecto.QueryError ->
        Logger.error("Database query failed: #{inspect(e)}")
        {:error, "Database query failed"}

      e ->
        Logger.error("Database error: #{inspect(e)}")
        {:error, "Failed to fetch from database"}
    end
  end

  @doc """
  Processes a single row of CSV data.
  Can be overridden for custom processing logic.
  """
  def process_row(row) do
    row
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_value/1)
  end

  @doc """
  Processes a database record.
  Can be overridden for custom processing logic.
  """
  def process_database_row(record) do
    # Default implementation returns the record as is
    # Override this function for custom processing
    record
  end

  @doc """
  Attempts to parse string values into appropriate types.
  """
  def parse_value(value) when is_binary(value) do
    cond do
      Regex.match?(~r/^\d+$/, value) ->
        String.to_integer(value)

      Regex.match?(~r/^\d*\.\d+$/, value) ->
        String.to_float(value)

      value in ["true", "false"] ->
        String.to_existing_atom(value)

      true ->
        value
    end
  end

  def parse_value(value), do: value
end
# Loading from CSV
{:ok, data} = DataLoader.load("path/to/file.csv")

# Loading from database
config = %{
  type: :database,
  repo: MyApp.Repo,
  schema: MyApp.MySchema
}
{:ok, data} = DataLoader.load(config)
