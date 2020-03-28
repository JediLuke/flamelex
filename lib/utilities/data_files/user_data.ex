defmodule Utilities.Data do


  def user_data_file_path do
    #TODO this magically works because of mix? but should be better really
    File.cwd! <> "/data/user.data"
  end

  def write(map) when is_map(map) do
    write(map, user_data_file_path()) # default to use data
  end
  def write(map, filepath) when is_map(map) do
    map
    |> Jason.encode!
    |> write_binary(filepath)
  end

  def read do
    read(user_data_file_path())
  end
  def read(file_path) do
    case File.read(file_path) do
      {:ok, ""} ->
        %{} # we treat this file as a map that gets saves to disk. Empty file -> empty map
      {:ok, file_contents} ->
        file_contents |> Jason.decode!
    end
  end

  defp write_binary(data, file_path) when is_binary(data) do
    {:ok, file} = File.open(file_path, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
