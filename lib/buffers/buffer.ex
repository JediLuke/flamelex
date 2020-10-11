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
