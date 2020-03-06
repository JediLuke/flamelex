defmodule Utilities.DataFile do

  def data_file_path do
    #TODO this magically works because of mix? but should be better really
    File.cwd! <> "/data/franklin.data"
  end

  def write(map) when is_map(map) do
    map
    |> Jason.encode!
    |> write_binary()
  end

  def read do
    case File.read(data_file_path()) do
      {:ok, ""} ->
        %{} # we treat this file as a map that gets saves to disk. EMpty file -> empty map
      {:ok, file_contents} ->
        file_contents |> Jason.decode!
    end
  end

  defp write_binary(data) when is_binary(data) do
    {:ok, file} = File.open(data_file_path(), [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
