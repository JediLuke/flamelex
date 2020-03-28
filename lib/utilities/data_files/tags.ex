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
        file_contents |> :erlang.binary_to_term()
    end
  end

  def new_tag(new_tag) when is_binary(new_tag) do
    all_tags() ++ [new_tag]
    |> :erlang.term_to_binary()
    |> write_binary(tags_file())
  end

  defp write_binary(data, file_path) when is_binary(data) do
    {:ok, file} = File.open(file_path, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end
end
