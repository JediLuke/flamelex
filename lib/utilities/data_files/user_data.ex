# defmodule Utilities.Data do
#   alias Structs.TidBit

#   #TODO we probably need locking on this MOFO :( - use a process & use GenServer.call, done.

#   def user_data_file_path do
#     #TODO this magically works because of mix? but should be better really
#     File.cwd! <> "/data/user.data"
#   end

#   def read do
#     read(user_data_file_path())
#   end
#   def read(file_path) do
#     case File.read(file_path) do
#       {:ok, ""} ->
#         %{} # we treat this file as a map that gets saves to disk. Empty file -> empty map
#       {:ok, file_contents} ->
#         %{"data" => %{} = data} = Jason.decode!(file_contents)
#         data #TODO need to convert all these to TidBits
#     end
#   end

#   def append(data) do
#     read()
#     |> Map.merge(%{data.uuid => data})
#     |> write()
#   end

#   def replace_tidbit(%TidBit{uuid: old_id}, %TidBit{uuid: new_id} = new_tidbit) when old_id == new_id do
#     read()
#     # |> Enum.reject(& &1.uuid == old_id)
#     |> Map.merge(new_tidbit)
#     |> write()
#   end

#   def find(tags: t) when is_binary(t) do
#     #TODO for now we find all with this tag, but this wil get more complicated
#     #TODO pretty sure this is n^2 lol
#     #TODO although it's N^2, this is a pretty nifty line of code!
#     read()
#     |> Enum.filter(fn {_key, data} -> data["tags"] |> Enum.member?(t) end)
#   end


#   ## private functions
#   ## -------------------------------------------------------------------


#   defp write(map) when is_map(map) do
#     write(map, user_data_file_path()) # default to use data
#   end
#   defp write(map, filepath) when is_map(map) do
#     %{data: map}
#     |> Jason.encode!
#     |> write_binary(filepath)
#   end

#   defp write_binary(data, file_path) when is_binary(data) do
#     {:ok, file} = File.open(file_path, [:write])
#     IO.binwrite(file, data)
#     File.close(file) # returns :ok
#   end
# end
