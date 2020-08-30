defmodule GUI.Root.Reducer do
  @moduledoc """
  This module contains functions which process events received from the GUI.

  #TODO this could be a pretty nice use case for a behaviour, but I like having the automatic pattern-match we get from importing modules #TODO num2 - actually, when it comes to applying layers, pushing actions through layers of reducers (with most important last, so they apply their actions over the top of other ones) might be a good model to use...
  In Franklin, a Reducer must always return one of three values

    :ignore                           -> causes GUI.Root.Scene to ignore action
    {new_state, new_graph}            -> causes GUI.Root.Scene to update both it's internal state, & push a new graph
    new_state when is_map(new_state)  -> causes GUI.Root.Scene to update it's internal state, but no change to the %Scenic.Graph{} is necessary

  """
  require Logger
  alias GUI.Structs.Frame

  @command_buffer_height 32



  def initialize(opts) do
    state = GUI.Structs.RootScene.new(opts)
    graph = GUI.Utilities.Draw.blank_graph()

    {state, graph} #NOTE: can't use update_state_and_graph here cause init doesn't handle that
  end

  def process({state, _graph}, 'ACTIVATE_COMMAND_BUFFER') do #TODO why not make this an atom
    # we need to do 2 separate things here,
    #   1) Send a msg to CommandBuffer (separate process) to show itself
    #   2) Update the state of the Scene.Root, because this state affects what inputs get mapped to
    GUI.Component.CommandBuffer.activate()
    put_in(state.input.mode, :command) |> update_state_only()
  end

  # def process({state, graph}, {'NEW_FRAME', [type: :text, content: content]}) do
  #   new_graph =
  #     graph
  #     |> GUI.Utilities.Draw.text(content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

  #   update_state_and_graph(state, new_graph) #TODO do we update the state??
  # end

  def process({%{viewport: vp} = state, graph}, {:initialize_command_buffer, buf}) do

    buffer_frame =
      buf |> Frame.new(
               top_left_corner: {0, vp.height - @command_buffer_height},
               dimensions:      {vp.width + 1, @command_buffer_height}, opts: []) #TODO why do we need that +1?? Without it, you can definitely see a thin black line on the edge

    new_graph =
      graph
      |> GUI.Component.CommandBuffer.add_to_graph(buffer_frame)

    update_state_and_graph(state, new_graph) #TODO do we need to update the root state at all? I hope not
  end


  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this (which right
  # now is GUI.Root.Scene !!) can crash (!!) if no action matches what
  # is passed in.
  def process({_state, _graph}, action) do
    Logger.warn "#{__MODULE__} received an action it did not recognise. #{inspect action}"
    ignore_this_action()
  end

  defp ignore_this_action(), do: :ignore_action
  defp update_state_only(new_state), do: {:update_state, new_state}
  defp update_state_and_graph(new_state, new_graph), do: {:update_all, {new_state, new_graph}}
end


## TODO - below be dragons!




















#   # def initialize(%{buffers: [%{id: :command_buffer}, %{id: {:text_editor, 1, :untitled}, active: true}]} = state) do
#   #   %{viewport: %{width: w, height: h}} = state
#   #   command_buffer = state.buffers |> hd()

#   #   graph =
#   #     Scenic.Graph.build(font: @ibm_plex_mono, font_size: @text_size)
#   #     # |> GUI.Component.TextEditor.add_to_graph(%{
#   #     #     id: {:text_editor, 1, :untitled},
#   #     #     top_left_corner: {0, 0},
#   #     #     dimensions: {w, h - command_buffer.data.height},
#   #     #     contents: "This is an editor buffer.\n\nYou are using Franklin."
#   #     #   })



#   #     #TODO we do want this just not here


#   #   {state, graph}
#   # end

#   def process({%{viewport: %{width: w}} = state, graph}, {'NEW_NOTE_COMMAND', contents, buffer_pid: buf_pid}) do
#     width  = w / 3
#     height = width
#     top_left_corner_x = (w/2)-(width/2) # center the box
#     top_left_corner_y = height / 5
#     id = {:note, generate_note_buffer_id(state.component_ref), buf_pid}

#     {:note, note_num, _buf_pid} = id
#     multi_note_offset = (note_num - 1) * 15

#     new_graph =
#       graph
#       |> GUI.Component.Note.add_to_graph(%{
#            id: id,
#            top_left_corner: {top_left_corner_x + multi_note_offset, top_left_corner_y + multi_note_offset},
#            dimensions: {width, height},
#            contents: contents
#          }, id: id)

#     new_state =
#       state
#       |> Map.replace!(:active_buffer, id)
#       |> Map.replace!(:mode, :edit)

#     {new_state, new_graph}
#   end

#   def process({%{viewport: %{width: w, height: h}} = state, graph}, {'NEW_LIST_BUFFER', data}) do

#     # state = DataFile.read()
#     command_buffer = state.buffers |> hd()
#     # id = {:list, :notes, buf_pid}
#     id = {:list, :notes}

#     new_graph =
#       graph
#       |> GUI.Component.List.add_to_graph(%{
#           id: id,
#           top_left_corner: {0, 0},
#           # dimensions: {w, h - command_buffer.data.height - 1}, #TODO this does put 1 pixel between the two, do we want that??
#           dimensions: {w, h - command_buffer.data.height},
#           contents: data
#         }, id: id)

#     new_state =
#       state
#       |> Map.replace!(:active_buffer, id)
#       # |> Map.replace!(:mode, :edit)

#     {new_state, new_graph}

#     # ibm_plex_mono = GUI.Initialize.ibm_plex_mono_hash()

#     # add_notes =
#     #   fn(graph, notes) ->
#     #     {graph, _offset_count} =
#     #       Enum.reduce(notes, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
#     #         graph =
#     #           graph
#     #           |> Scenic.Primitives.group(fn graph ->
#     #                graph
#     #                |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
#     #                |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
#     #                    translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#     #                    font_size: 24, fill: :black)
#     #              end)


#     #         {graph, offset_count + 1}
#     #       end)
#     #     graph
#     #   end

#     # new_graph =
#     #   graph |> add_notes.(notes)

#   end

#   def process({state, _graph}, {'NOTE_INPUT', {:note, _x, _pid} = active_buffer, input}) do
#     [{{:note, _x, buffer_pid}, component_pid}] =
#       state.component_ref
#       |> Enum.filter(fn
#            {^active_buffer, _pid} ->
#             true
#          _else ->
#             false
#          end)

#     Franklin.Buffer.Note.input(buffer_pid, {component_pid, input})
#     state
#   end

#   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'}) do
#     find_component_reference_pid!(state.component_ref, active_buffer_id)
#     |> GUI.Component.Note.move_cursor_to_text_section
#     state
#   end

#   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, graph}, {:active_buffer, :note, 'CLOSE_NOTE_BUFFER'}) do

#     # find_component_reference_pid!(state.component_ref, active_buffer_id)
#     # |> GUI.Component.Note.close_buffer

#     new_graph =
#       graph |> Scenic.Graph.delete(active_buffer_id)

#     #TODO here we can de-link the component

#     {state, new_graph}
#   end

#   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'}) do
#     find_component_reference_pid!(state.component_ref, active_buffer_id)
#     |> GUI.Component.Note.move_cursor_to_title_section
#     state
#   end

#   defp generate_note_buffer_id(component_ref) when is_list(component_ref) do
#     component_ref
#     |> Enum.filter(fn
#          {{:note, _x, _buf_pid}, _pid} ->
#              true
#          _else ->
#              false
#        end)
#     |> Enum.count
#     |> (&(&1 + 1)).()
#   end
# end