defmodule Utilities.DataFiles.Tags do
  #TODO make this human readable, dont use term_to_binary/1

  def tags_file do
    #TODO this magically works because of mix? but should be better really
    #TODO make this a config somewhere
    File.cwd! <> "/data/tags.data"
  end

  def all_tags do
    case File.read(tags_file()) do
      {:ok, ""} ->
        []
      {:ok, file_contents} ->
        %{"tags" => tags} = file_contents |> Jason.decode!
        tags
    end
  end

  def new_tag(new_tag) when is_binary(new_tag) do
    tags = all_tags() ++ [new_tag]
    %{tags: tags} |> write(tags_file())
  end

  defp write(map, filepath) when is_map(map) do
    map
    |> Jason.encode!
    |> write_binary(filepath)
  end

  defp write_binary(data, file_path) when is_binary(data) do
    {:ok, file} = File.open(file_path, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
