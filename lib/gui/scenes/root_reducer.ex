defmodule GUI.RootReducer do
  @moduledoc """
  This module contains functions which process events received from the GUI.
  """
  require Logger

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

  def process({%{viewport: %{width: w, height: h}} = state, graph}, 'NEW_NOTE_COMMAND') do
    width  = w / 3
    height = width
    top_left_corner_x = (w/2)-(width/2) # center the box
    top_left_corner_y = height / 5
    new_graph =
      graph
      |> GUI.Component.Note.add_to_graph(%{
           id: :untitled_note,
           top_left_corner: {top_left_corner_x, top_left_corner_y},
           dimensions: {width, height}
         })
    {state, new_graph}
  end
end
