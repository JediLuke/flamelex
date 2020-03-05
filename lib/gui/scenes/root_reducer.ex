defmodule GUI.RootReducer do
  @moduledoc """
  This module contains functions which process events received from the GUI.
  """
  require Logger
  import Utilities.ComponentUtils

  def process({%{command_buffer: %{visible?: false}} = state, _graph}, 'SHOW_COMMAND_BUFFER') do
    {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
    new_command_buffer_map =
      state.command_buffer
      |> Map.replace!(:visible?, true)

    GenServer.cast(pid, {:action, 'SHOW_COMMAND_BUFFER'})
    %{state|command_buffer: new_command_buffer_map}
  end

  def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'CLEAR_AND_CLOSE_COMMAND_BUFFER') do
    new_command_buffer_map =
      state.command_buffer |> Map.replace!(:visible?, false)

    {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
    GenServer.cast(pid, {:action, 'CLEAR_BUFFER_TEXT'})
    GenServer.cast(pid, {:action, 'HIDE_COMMAND_BUFFER'})

    %{state|command_buffer: new_command_buffer_map}
  end

  def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE' = action) do
    {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
    GenServer.cast(pid, {:action, action})
    state
  end

  def process({%{command_buffer: %{visible?: true}} = state, _graph}, {'COMMAND_BUFFER_INPUT', _input} = action) do
    {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
    GenServer.cast(pid, {:action, action})
    state
  end

  def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'PROCESS_COMMAND_BUFFER_TEXT_AS_COMMAND' = action) do
    {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
    GenServer.cast(pid, {:action, action})
    state
  end

  def process({%{viewport: %{width: w}} = state, graph}, {'NEW_NOTE_COMMAND', contents, buffer_pid: buf_pid}) do
    width  = w / 3
    height = width
    top_left_corner_x = (w/2)-(width/2) # center the box
    top_left_corner_y = height / 5
    id = {:note, generate_note_buffer_id(state.component_ref), buf_pid}

    {:note, note_num, _buf_pid} = id
    multi_note_offset = (note_num - 1) * 15

    new_graph =
      graph
      |> GUI.Component.Note.add_to_graph(%{
           id: id,
           top_left_corner: {top_left_corner_x + multi_note_offset, top_left_corner_y + multi_note_offset},
           dimensions: {width, height},
           contents: contents
         })
    {state |> Map.replace!(:active_buffer, id), new_graph}
  end

  def process({state, _graph}, {'NOTE_INPUT', {:note, _x, _pid} = active_buffer, input}) do
    [{{:note, _x, buffer_pid}, component_pid}] =
      state.component_ref
      |> Enum.filter(fn
           {^active_buffer, _pid} ->
            true
         _else ->
            false
         end)

    Franklin.Buffer.Note.input(buffer_pid, {component_pid, input})
    state
  end

  def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'}) do
    find_component_reference_pid!(state.component_ref, active_buffer_id)
    |> GUI.Component.Note.move_cursor_to_text_section
    state
  end

  defp generate_note_buffer_id(component_ref) when is_list(component_ref) do
    component_ref
    |> Enum.filter(fn
         {{:note, _x, _buf_pid}, _pid} ->
             true
         _else ->
             false
       end)
    |> Enum.count
    |> (&(&1 + 1)).()
  end
end
