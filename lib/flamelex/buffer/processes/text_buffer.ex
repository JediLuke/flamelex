defmodule Flamelex.Buffer.Text do
  @moduledoc """
  A buffer to hold & manipulate text.
  """
  use Flamelex.BufferBehaviour
  alias Flamelex.Buffer.Utils.TextBufferUtils
  alias Flamelex.Buffer.Utils.TextBuffer.ModifyHelper
  alias Flamelex.Buffer.Utils.CursorMovementUtils, as: MoveCursor
  require Logger


  @impl Flamelex.BufferBehaviour
  def boot_sequence(%{source: {:file, filepath}} = params) do
    Logger.info "#{__MODULE__} booting up... #{inspect params, pretty: true}"

    {:ok, file_contents} = File.read(filepath)

    init_state =
      params |> Map.merge(%{
        data: file_contents,    # the raw data
        unsaved_changes?: false,  # a flag to say if we have unsaved changes
        # time_opened #TODO
        cursors: [%{line: 1, col: 1}],
        lines: file_contents |> TextBufferUtils.parse_raw_text_into_lines()
      })

    {:ok, init_state}
  end

  def find_supervisor_pid(%{rego_tag: rego_tag = {:buffer, _details}}) do
    ProcessRegistry.find!({:buffer, :task_supervisor, rego_tag})
  end

  #TODO right now, this only works for one cursor, i.e. cursor-1
  def handle_call({:get_cursor_coords, 1}, _from, %{cursors: [c]} = state) do
    {:reply, c, state}
  end

  def handle_call(:get_num_lines, _from, state) do
    {:reply, Enum.count(state.lines), state}
  end

  @impl GenServer
  def handle_call(:save, _from, %{source: {:file, _filepath}} = state) do
    {:ok, new_state} = TextBufferUtils.save(state)
    {:reply, :ok, new_state}
  end

  def handle_cast(:close, %{unsaved_changes?: true} = state) do
    #TODO need to raise a bigger alarm here
    Logger.warn "unable to save buffer: #{inspect state.rego_tag}, as it contains unsaved changes."
    {:noreply, state}
  end

  def handle_cast(:close, %{unsaved_changes?: false} = state) do
    # {:buffer, source} = state.rego_tag
    # Logger.warn "Closing a buffer... #{inspect source}"
    # ModifyHelper.cast_gui_component(source, :close)
    IO.puts "#TODO need to actually close the buffer - close the FIle?"

    # ProcessRegistry.find!({:gui_component, state.rego_tag}) #TODO this should be a GUI.Component.TextBox, not, :gui_component !!
    # |> GenServer.cast(:close)

    GenServer.cast(Flamelex.GUI.Controller, {:close, state.rego_tag})

    {:stop, :normal, state}
  end

  def handle_cast({:move_cursor, instructions}, state) do
    start_sub_task(state, MoveCursor,
                          :move_cursor_and_update_gui,
                          instructions)
    {:noreply, state}
  end

  def handle_cast({:modify, details}, state) do
    ModifyHelper.start_modification_task(state, details)
    {:noreply, state}
  end


  # when a Task completes, if successful, it will most likely callback -
  # so we update the state of the Buffer, & trigger a GUI update
  #TODO maybe this is a little ambitious... we can just do what MoveCursor does, and have the task directly call the GUI to update it specifically
  # def handle_cast({:state_update, new_state}, %{rego_tag: buffer_rego_tag = {:buffer, _details}}) do
  #   PubSub.broadcast(
  #     topic: :gui_update_bus,
  #       msg: {buffer_rego_tag, {:new_state, new_state}})
  #   {:noreply, new_state}
  # end

  def handle_cast({:state_update, new_state}, _old_state) do
    IO.puts "#{__MODULE__} updating state - #{inspect new_state.data}"
    #TODO need to update the GUI here?
    {:noreply, new_state}
  end


  # spin up a new process to do the handling...
  defp start_sub_task(state, module, function, args) do
  Task.Supervisor.start_child(
      find_supervisor_pid(state), # start the task under the Task.Supervisor specific to this Buffer
          module,
          function,
          [state, args])
  end
end
