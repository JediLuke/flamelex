defmodule Structs.TidBit do
  @moduledoc false
  require Logger

  defguard is_valid(data) when is_map(data)

  @derive Jason.Encoder
  defstruct [
    uuid: nil,
    hash: nil,
    title: nil,
    tags: [],
    creation_timestamp: nil,
    content: nil
  ]

  def initialize(data), do: validate(data) |> create_struct()


  ## private functions
  ## -------------------------------------------------------------------


  defp validate(%{title: t, tags: tags, content: c} = data)
    when is_binary(t) and is_list(tags) and is_binary(c) do
      data = data |> Map.merge(%{
        uuid: UUID.uuid4(),
        creation_timestamp: DateTime.utc_now()
      })

      # take a hash of all other elements in the map
      hash =
        :crypto.hash(:md5, data |> Jason.encode!())
        |> Base.encode16()
        |> String.downcase()
      data |> Map.merge(%{hash: hash}) #TODO test this hashing thing
  end
  defp validate(_else), do: :invalid_data

  defp create_struct(:invalid_data), do: raise "Invalid data provided when initializing #{__MODULE__}."
  defp create_struct(data), do: struct(__MODULE__, data)

end
