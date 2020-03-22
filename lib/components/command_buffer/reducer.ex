defmodule GUI.Components.CommandBuffer.Reducer do
  @moduledoc """
  This module contains reducer functions - they take in a graph, & an
  'action' (usually a string, sometimed with some params) and return a
  mutated state and/or graph.
  """
  alias GUI.Components.CommandBuffer.DrawingFunctions, as: Draw
  require Logger

  # import Scenic.{Primitive, Primitives}
  # alias Scenic.Graph
  # require Logger

  def initialize(state, opts) do
    Draw.blank_graph(opts)
    |> Draw.echo_buffer(state)
  end

  # @empty_command_buffer_text_prompt "Enter a command..."

  # def process({%{mode: :echo} = state, _graph}, 'ACTIVATE_COMMAND_BUFFER_PROMPT') do
  #   new_graph =
  #     Scenic.Graph.build()
  #       |> group(fn graph ->
  #         graph
  #         |> draw_background(state)
  #         |> draw_command_prompt(state)
  #         |> add_blinking_box_cursor(state)
  #         |> draw_command_prompt_text(state)
  #       end, [
  #         id: :command_buffer,
  #       #  hidden: true
  #       ])

  #   new_state =
  #     state
  #     |> Map.replace!(:mode, :command)

  #   {new_state, new_graph}
  # end

  # def process({state, graph}, 'DEACTIVATE_COMMAND_BUFFER') do
  #   #TODO remove all text from the string etc.
  #   new_graph =
  #     graph |> Scenic.Graph.modify(:command_buffer, fn primitive ->
  #       primitive |> Scenic.Primitive.put_style(:hidden, true)
  #     end)

  #   {:noreply, {state, new_graph}, push: new_graph}
  # end

  # def process({state, graph}, {'COMMAND_BUFFER_INPUT', {:codepoint, {letter, x}}}) when x in [0, 1] do # need the check on x because lower and uppercase letters have a different number here for some reason
  #   updated_buffer_text = state.text <> letter
  #   new_state = state |> Map.replace!(:text, updated_buffer_text)

  #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  #   GenServer.cast(pid, {:action, 'MOVE_RIGHT_ONE_COLUMN'})

  #   new_graph =
  #     graph
  #     |> Graph.modify(:buffer_text, &text(&1, updated_buffer_text, fill: :ghost_white))

  #   {new_state, new_graph}
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
    state
  end
end
