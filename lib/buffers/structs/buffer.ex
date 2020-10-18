# defmodule Flamelex.Structs.Buffer do
#   @moduledoc false
#   alias GUI.Structs.{Coordinates, Dimensions, Frame}

#   defstruct [
#     type:     nil,              # We support many types of buffer, e.g. :text, :list, :gfx
#     # tag:      nil,              # An identifier. Can be any type, e.g. "CommandBuffer", "oinap982q43un2>2f0", "luke and {:cursor, 1} are all valid. We use this to look up all related processes in gproc
#     name:     nil,
#     # title:    nil,              # An optional title
#     content:  nil,              # This field contains all the actual content of the buffer
#     # gui: %{                     # A buffer, when linked to the GUI, is responsible for managing & updating it's own GUI state
#     #   frame:  %Frame{},         # The Frame is the Flamelex concept of the box which this buffer controls
#     #   graph:  %Scenic.Graph{}   # The Graph is the actual GUI content. This gets updated when we re-draw the GUI
#   ]

#   # Utilities.ProcessRegistry.fetch_buffer_pid!(file_name) |> Franklin.Buffer.Text.insert("WooLoo", [after: 3])

#   # def initialize(data), do: validate(data) |> create_struct()

#   # def ack_reminder(reminder = %__MODULE__{tags: old_tags}) when is_list(old_tags) do
#   #   new_tags =
#   #     old_tags
#   #     |> Enum.reject(& &1 == "reminder")
#   #     |> Enum.concat(["ackd_reminder"])

#   #   reminder |> Map.replace!(:tags, new_tags)
#   # end

#   def new(:command) do
#     %__MODULE__{
#       type:          :command,
#       name:          "CommandBuffer",
#       content:       nil
#     }
#   end

#   #TODO kind of inelegant...
#   def new({:text, name, content}) do
#     %__MODULE__{
#       type:    :text,
#       name:    name,
#       content: content
#     }
#   end

#   #TODO add number??
#   def rego(%__MODULE__{name: name}), do: {:buffer, name}
#   def rego(name), do: {:buffer, name}

#   def update_content(%__MODULE__{} = buf, with: c) do
#     %{buf|content: c}
#   end

#   # ## private functions
#   # ## -------------------------------------------------------------------


#   # defp validate(%{title: t, tags: tags, content: c} = data)
#   #   when is_binary(t) and is_list(tags) and is_binary(c) do
#   #     data = data |> Map.merge(%{
#   #       uuid: UUID.uuid4(),
#   #       creation_timestamp: DateTime.utc_now()
#   #     })

#   #     # take a hash of all other elements in the map
#   #     hash =
#   #       :crypto.hash(:md5, data |> Jason.encode!())
#   #       |> Base.encode16()
#   #       |> String.downcase()
#   #     data |> Map.merge(%{hash: hash}) #TODO test this hashing thing
#   # end
#   # defp validate(_else), do: :invalid_data

#   # defp create_struct(:invalid_data), do: raise "Invalid data provided when initializing #{__MODULE__}."
#   # defp create_struct(data), do: struct(__MODULE__, data)


#   # def update_content(%Buffer{} = buf, with: c) do
#   #   %{buf|content: c}
#   # end

# end
