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
    Logger.info "#{__MODULE__} booting up..."

    {:ok, file_contents} = File.read(filepath)

    init_state =
      params |> Map.merge(%{
        data: file_contents,    # the raw data
        unsaved_changes?: nil,  # a flag to say if we have unsaved changes
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

  def handle_cast(:close, state) do
    if state.unsaved_changes? do
      raise "need to be able to interact with the user here I guess..."
    else
      Logger.warn "Closing a buffer..."
      {:stop, :normal, state}
    end
  end

  def handle_cast({:move_cursor, instructions}, state) do
    start_sub_task(state,
        MoveCursor, :move_cursor_and_update_gui, instructions)
    {:noreply, state}
  end

  def handle_cast({:modify_buffer, specifics}, state) do
    ModifyHelper.start_modification_task(state, specifics)
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

  def handle_cast({:state_update, new_state}, %{rego_tag: buffer_rego_tag = {:buffer, _details}}) do
    {:noreply, new_state}
  end

  def handle_cast({:state_update, :no_gui_change, new_state}, %{rego_tag: buffer_rego_tag = {:buffer, _details}}) do
    {:noreply, new_state}
  end

  # spin up a new process to do the handling...
  defp start_sub_task(state, module, function, args) do
  Task.Supervisor.start_child(
      # start the task under the Task.Supervisor specific to this Buffer
      find_supervisor_pid(state),
          module,
          function,
          [state, args])
  end
end
