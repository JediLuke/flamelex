defmodule Utilities.Data do


  def user_data_file_path do
    #TODO this magically works because of mix? but should be better really
    File.cwd! <> "/data/user.data"
  end

  def read do
    read(user_data_file_path())
  end
  def read(file_path) do
    case File.read(file_path) do
      {:ok, ""} ->
        %{} # we treat this file as a map that gets saves to disk. Empty file -> empty map
      {:ok, file_contents} ->
        %{"data" => data} =
          file_contents
          |> Jason.decode!

        data
    end
  end

  def append(data) do
    read()
    |> Map.merge(%{data.uuid => data})
    |> write()
  end

  def find(tags: t) when is_binary(t) do
    #TODO for now we find all with this tag, but this wil get more complicated
    #TODO pretty sure this is n^2 lol
    #TODO although it's N^2, this is a pretty nifty line of code!
    read()
    |> Enum.filter(fn {_key, data} -> data["tags"] |> Enum.member?(t) end)
  end


  ## private functions
  ## -------------------------------------------------------------------


  defp write(map) when is_map(map) do
    write(map, user_data_file_path()) # default to use data
  end
  defp write(map, filepath) when is_map(map) do
    %{data: map}
    |> Jason.encode!
    |> write_binary(filepath)
  end

  defp write_binary(data, file_path) when is_binary(data) do
    {:ok, file} = File.open(file_path, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
