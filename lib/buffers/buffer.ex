defmodule Flamelex.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger
  use Flamelex.ProjectAliases


    # def display_buffer(%Buffer{} = buf) do
  #   #TODO use a struct here
  #   # def show_fullscreen(buffer), do: Flamelex.GUI.Controller.show_fullscreen(buffer)
  #   # def show_fullscreen(buffer), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN
  #   # def register_new_buffer(type: :text, content: content, action: 'OPEN_FULL_SCREEN'), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: content]})
  #   # def register_new_buffer(args), do: Flamelex.GUI.Controller.register_new_buffer(args)
  #   GenServer.cast(Flamelex.GUI.Controller, {:display_buffer, buf})
  # end

  # def register_new_buffer(args), do: GenServer.cast(__MODULE__, {:register_new_buffer, args})

  # def show_fullscreen(buffer), do: GenServer.cast(__MODULE__, {:show_fullscreen, buffer})

  # def fetch_active_buffer(), do: GenServer.call(__MODULE__, :fetch_active_buffer)


  @doc """
  Loading a buffer means taking data from some source (a local file, a web
  page, etc.) and putting it into the contents of a %Buffer{}, then starting
  a buffer process to be responsible for that data, maybe updating the GUI
  etc. to display it.
  """
  def load(type: :text, file: filepath) when is_bitstring(filepath) do
    Logger.info "Loading new text buffer for file: #{inspect filepath}"
    content = File.read!(filepath)
    Flamelex.Buffer.Supervisor.start_buffer_process(
                            type: Flamelex.Buffer.Text,
                            name: filepath,
                         content: content)
  end

  @doc """
  Inserting into a buffer lets us put text into a text buffer.
  """
  def insert(%Buffer{} = buf, string) do
    raise "no"
  end

  # def insert(file_name, string, opts) when is_bitstring(file_name) do
  #   file_name
  #   |> Utilities.ProcessRegistry.fetch_buffer_pid!()
  #   |> insert(string, opts)
  # end
  # def insert(buffer_pid, string, [after: x]) when is_pid(buffer_pid) do
  #   buffer_pid
  #   |> GenServer.cast({:insert_char, string, after: x})
  # end


  # def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  # def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
  # def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
  # def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
  # def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)

end





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
