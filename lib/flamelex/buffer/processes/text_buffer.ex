defmodule Flamelex.Buffer.Text do
  @moduledoc """
  A buffer to hold & manipulate text.
  """
  use Flamelex.BufferBehaviour
  alias Flamelex.Buffer.Utils.TextBufferUtils
  alias Flamelex.Buffer.Utils.TextBuffer.ModifyHelper
  require Logger


  @impl Flamelex.BufferBehaviour
  def boot_sequence(%{source: {:file, filepath}} = params) do
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
    #TODO so, these should all also have the same, Task.Supervisor pattern...
    {:ok, new_state} = TextBufferUtils.move_cursor(state, instructions)
    {:noreply, new_state}
  end

  def handle_cast({:modify_buffer, specifics}, state) do
    {:ok, new_state} = ModifyHelper.modify(state, specifics)
    {:noreply, new_state}
  end
end
