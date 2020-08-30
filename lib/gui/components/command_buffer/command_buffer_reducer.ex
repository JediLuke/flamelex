defmodule GUI.Component.CommandBuffer.Reducer do
  @moduledoc """
  This module contains reducer functions - they take in a graph, & an
  'action' (usually a string, sometimed with some params) and return a
  mutated state and/or graph.
  """
  alias Scenic.Graph
  alias GUI.Component.CommandBuffer.DrawingHelpers
  import Scenic.Primitives
  require Logger
  use Franklin.Misc.CustomGuards

  @component_id :command_buffer

  @command_mode_background_color :cornflower_blue

  def initialize(%Frame{} = frame) do

    # the textbox is internal to the command buffer, but we need the coordinates
    # of it in a few places, so we can just pre-calculate it up here
    %Frame{} = textbox_frame =
      DrawingHelpers.calc_textbox_frame(frame)

    Draw.blank_graph()
    |> group(fn graph ->
         graph
         |> Draw.background(frame, @command_mode_background_color)
         |> DrawingHelpers.draw_command_prompt(frame)
         |> DrawingHelpers.draw_input_textbox(textbox_frame)
         |> DrawingHelpers.draw_cursor(textbox_frame)
        #  |> draw_command_prompt_text(state)
    end, [
      id: @component_id,
      hidden: true
    ])
  end

  def process({_state, graph}, 'ACTIVATE_COMMAND_BUFFER') do #TODO this should just be an atom
    new_graph =
      graph
      |> Graph.modify(@component_id, &update_opts(&1, hidden: false))

    {:update_graph, new_graph}
  end

  def process({_state, graph}, 'DEACTIVATE_COMMAND_BUFFER') do #TODO this should just be an atom
    # def process({%{mode: :command} = state, _graph}, 'DEACTIVATE_COMMAND_BUFFER') do
    #   new_state =
    #     state
    #     |> Map.replace!(:mode, :echo)
    #     |> Map.replace!(:text, "Left `command` mode.")

    #   new_graph =
    #     Draw.echo_buffer(new_state)

    #   {new_state, new_graph}
    # end
    new_graph =
      graph
      |> Graph.modify(@component_id, &update_opts(&1, hidden: true))

    {:update_graph, new_graph}
  end

  # def process({_state, graph}, :move_cursor) do
  #   graph
  #   |> GUI.Component.Cursor.move()
  #   {:update_graph, new_graph}
  # end
end

  # # def process({state, graph}, {'ENTER_CHARACTER', {:codepoint, {letter, x}}}) when x in [0, 1] do # need the check on x because lower and uppercase letters have a different number here for some reason
  # def process({%{mode: :command} = state, graph}, {'ENTER_CHARACTER', char}) when is_binary(char) do
  #   updated_buffer_text =
  #     state.text <> char

  #   new_state =
  #     state |> Map.replace!(:text, updated_buffer_text)

  #   #TODO move the cursor
  #   # {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  #   # GenServer.cast(pid, {:action, 'MOVE_RIGHT_ONE_COLUMN'})

  #   # $TODO update text box - requres sending msg to text_buffer
  #   # new_graph =
  #   #   graph
  #   #   |> Graph.modify(:buffer_text, &text(&1, updated_buffer_text, fill: :blue))

  #   new_state
  # end


  # def process({%{text: ""} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE') do
  #   state
  # end
  # def process({state, graph}, 'COMMAND_BUFFER_BACKSPACE') do
  #   {backspaced_buffer_text, _last_letter} = state.text |> String.split_at(-1)

  #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  #   GenServer.cast(pid, {:action, 'MOVE_LEFT_ONE_COLUMN'})

  #   new_state = state |> Map.replace!(:text, backspaced_buffer_text)

  #   new_graph =
  #     case new_state.text do
  #       "" -> # render msg but keep text buffer as empty string
  #         graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  #       non_blank_string ->
  #         graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
  #     end

  #   {new_state, new_graph}
  # end

  # def process({state, graph}, 'CLEAR_BUFFER_TEXT') do
  #   new_state = state |> Map.replace!(:text, "")

  #   new_graph =
  #     graph
  #     |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))

  #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  #   GenServer.cast(pid, {:action, 'RESET_POSITION'})

  #   {new_state, new_graph}
  # end

  # def process({state, graph}, 'PROCESS_COMMAND_BUFFER_TEXT_AS_COMMAND') do
  #   Franklin.Commander.process(state.text)
  #   GUI.Scene.Root.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
  #   {state, graph}
  # end

  # #NOTE: This must go on the bottom, as it's the catch-all...
  def process({state, _graph}, unknown_action) do
    Logger.error "#{__MODULE__} received unknown state/action combination: action: #{inspect unknown_action}, state: #{inspect state}"
    :ignore_action
  end
end