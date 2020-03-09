defmodule GUI.RootReducer do
  @moduledoc """
  This module contains functions which process events received from the GUI.
  """
  require Logger
  import Utilities.ComponentUtils

  use GUI.Reducer.ControlMode

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
         }, id: id)

    new_state =
      state
      |> Map.replace!(:active_buffer, id)
      |> Map.replace!(:mode, :edit)

    {new_state, new_graph}
  end

  def process({%{viewport: %{width: w}} = state, graph}, {'NEW_LIST_NOTES_BUFFER', notes, buffer_pid: _buf_pid}) do
    ibm_plex_mono = GUI.Initialize.ibm_plex_mono_hash()

    add_notes =
      fn(graph, notes) ->
        {graph, _offset_count} =
          Enum.reduce(notes, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
            graph =
              graph
              |> Scenic.Primitives.group(fn graph ->
                   graph
                   |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
                   |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
                       translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
                       font_size: 24, fill: :black)
                 end)


            {graph, offset_count + 1}
          end)
        graph
      end

    new_graph =
      graph |> add_notes.(notes)

    {state, new_graph}
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

  def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, graph}, {:active_buffer, :note, 'CLOSE_NOTE_BUFFER'}) do

    # find_component_reference_pid!(state.component_ref, active_buffer_id)
    # |> GUI.Component.Note.close_buffer

    new_graph =
      graph |> Scenic.Graph.delete(active_buffer_id)

    #TODO here we can de-link the component

    {state, new_graph}
  end

  def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'}) do
    find_component_reference_pid!(state.component_ref, active_buffer_id)
    |> GUI.Component.Note.move_cursor_to_title_section
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
