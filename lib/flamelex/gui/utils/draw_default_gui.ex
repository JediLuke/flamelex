defmodule Flamelex.GUI.Utils.DefaultGUI do
  use Flamelex.ProjectAliases
  require Logger


#   # tiddlywiki
#   created: 20191106045137712
# modified: 20191106045315363
# tags: dubber
# title: Using the `luketest` account in dev.dubber.io rails console
# tmap.id: cdef6cc3-4881-4934-978f-6146f2a99c58
# type: text/vnd.tiddlywiki

# ```
# luketest = Dub::Account.where(slug: 'luketest').first
# luketest.recordings.last
# ```




  def draw(%{viewport: vp}) do

    #TODO this should probably be pre-compiled
    Scenic.Graph.build()
    # |> draw_layer(1, "The transmutation circle")
    # |> draw_layer(2, "")
    # |> draw_layer(3, "Active Buffer")
    # |> draw_layer(4, "Interrupts/Popups")
    # |> draw_layer(5, "Menubar")
    # |> draw_layer(6, "Kommander")
    # |> draw_layer(7, "")

  end

  #NOTE: Layers need to be able to be hidden/shown, and then rendered on
  #      top of each other


  def draw_transmutation_circle(graph, vp) do

    #NOTE: We need the Frame here, so here is where we need to calculate
    #      how to position the TransmutationCicle in the middle of the viewport
    center_point = Dimensions.find_center(vp)
    scale_factor = 600 # how big the square frame becomes

    top_left_x_for_centered_frame = center_point.x - scale_factor/2
    top_left_y_for_centered_frame = center_point.y - scale_factor/2

    graph
    |> Flamelex.GUI.Component.TransmutationCircle.mount(
          %{ref: :renseijin,
            frame: Frame.new(
                     top_left: {top_left_x_for_centered_frame, top_left_y_for_centered_frame},
                     size:     {scale_factor, scale_factor})})
  end


  defp mount_menubar(graph, vp) do
    graph
    |> Flamelex.GUI.Component.MenuBar.mount(%{
         ref: :menu_bar,
         frame: Frame.new(
            top_left: {0, 0},
            size:     {vp.width, Flamelex.GUI.Component.MenuBar.height()})})
  end

  defp mount_kommand_buffer(graph, vp) do
    Logger.debug "mounting KommandBuffer..."
    graph
    |> Flamelex.GUI.Component.KommandBuffer.mount(%{
         ref: :kommand_buffer,
         frame: Frame.new(
            top_left: {0, vp.height - Flamelex.GUI.Component.MenuBar.height()},
            size:     {vp.width, Flamelex.GUI.Component.MenuBar.height()})
       })
  end
end

















  # defmodule Flamelex.GUI.Root.Reducer do
#   @moduledoc """
#   This module contains functions which process events received from the GUI.

#   #TODO this could be a pretty nice use case for a behaviour, but I like having the automatic pattern-match we get from importing modules #TODO num2 - actually, when it comes to applying layers, pushing actions through layers of reducers (with most important last, so they apply their actions over the top of other ones) might be a good model to use...
#   In Franklin, a Reducer must always return one of three values

#     :ignore                           -> causes Flamelex.GUI.RootScene to ignore action
#     {new_state, new_graph}            -> causes Flamelex.GUI.RootScene to update both it's internal state, & push a new graph
#     new_state when is_map(new_state)  -> causes Flamelex.GUI.RootScene to update it's internal state, but no change to the %Scenic.Graph{} is necessary

#   """
#   require Logger
#   use Flamelex.{ProjectAliases, CustomGuards}



#   # def process(
#   #       %{
#   #         layout:
#   #           %Flamelex.GUI.Structs.Layout{
#   #             arrangement: :floating_frames,
#   #             # dimensions: %Flamelex.GUI.Structs.Dimensions{width: width, height: height},
#   #             frames: []
#   #           }
#   #       } = state,
#   #       {:show_in_gui, buf} = _action) do

#   #   # #TODO we want to use frames etc. but this is more or less it!
#   #   # %{arrangement: _arrangement,
#   #   #    dimensions: %{width: width, height: height}}
#   #   #      = state.layout

#   #   new_frame = Frame.new(
#   #     id:              1, #NOTE: This is ok, because this pattern match is for when we have no frames
#   #     top_left_corner: {25, 25},
#   #     dimensions:      {800, 1200},
#   #     buffer:          buf)

#   #       # picture_graph:   GUI.Component.TextBox.new(buf)
#   #       # picture_graph:   Draw.blank_graph()
#   #       #                  |> Draw.text("Yes yes", {100, 100}) #TODO although inelegant, this is drawing text inside the frame!!

#   #   #TODO need to make sure our ordering is correct so frames are layered on top of eachother
#   #   new_graph =
#   #     state.graph
#   #     # |> GUI.Component.Frame.add_to_graph(new_frame)

#   #   new_layout =
#   #     %{state.layout|frames: state.layout.frames ++ [new_frame]}

#   #   new_state =
#   #     %{state|graph: new_graph, layout: new_layout}

#   #   {:redraw_root_scene, new_state}
#   # end


#   # def process(
#   #   %{
#   #     layout:
#   #       %Flamelex.GUI.Structs.Layout{
#   #         arrangement: :floating_frames,
#   #         # dimensions: %Flamelex.GUI.Structs.Dimensions{width: width, height: height},
#   #         frames: [%Frame{} = f] # one frame
#   #       }
#   #   } = state,
#   #   {:show_in_gui, buf} = _action) do


#   #     new_frame = Frame.new(
#   #       id:              2,
#   #       top_left_corner: {850, 25},
#   #       dimensions:      {800, 1200},
#   #       buffer:          buf)


#   #     #TODO need to make sure our ordering is correct so frames are layered on top of eachother
#   #     new_graph =
#   #       state.graph
#   #       # |> GUI.Component.Frame.add_to_graph(new_frame)

#   #     new_layout =
#   #       %{state.layout|frames: state.layout.frames ++ [new_frame]}

#   #     new_state =
#   #       %{state|graph: new_graph, layout: new_layout}

#   #     {:redraw_root_scene, new_state}
#   # end

#   # def process(
#   # %{layout: %Flamelex.GUI.Structs.Layout{
#   #       arrangement: :floating_frames,
#   #       frames: frame_list}
#   # } = state,
#   # {:show_in_gui, buf} = _action)
#   # when length(frame_list) > 2 do
#   #   IO.puts ""

#   # end

#   #TODO this is a protocol
#   #
#   # defprotocol Utility do
#   #   @spec type(t) :: String.t()
#   #   def type(value)
#   # end

#   # defimpl Utility, for: BitString do
#   #   def type(_value), do: "string"
#   # end

#   # defimpl Utility, for: Integer do
#   #   def type(_value), do: "integer"
#   # end





#   def process(state, {:show, buf}) do

#     new_frame = Frame.new(
#       id:              9,
#       top_left_corner: {100, 100},
#       dimensions:      {200, 200},
#       buffer:          buf)


#     new_graph =
#       state.graph
#       # |> GUI.Component.Frame.add_to_graph(new_frame)

#     new_state =
#       %{state|graph: new_graph}

#     {:redraw_root_scene, new_state}
#   end


#   def process(a, b) do
#     IO.inspect b, label: "ACTION"
#     raise "NO #{inspect a} #{inspect b}"
#   end




#   # def process({_scene, graph}, {:show_in_gui, %BufRef{} = buf}) do
#   #   new_graph =
#   #     graph
#   #     |> GUI.Utilities.Draw.text(buf.content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

#   #   {:update_graph, new_graph}
#   # end


#   #TODO this at the moment renders a new Text frame
#   # def process({state, graph}, {'NEW_FRAME', [type: :text, content: content]}) do
#   #   new_graph =
#   #     graph
#   #     |> GUI.Utilities.Draw.text(content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

#   #   # update_state_and_graph(state, new_graph) #TODO do we update the state??
#   #   {:update_all, {state, new_graph}}
#   # end


#   # defp update_state_and_graph(new_state, new_graph), do: {:update_all, {new_state, new_graph}}
# end


# ## TODO - below be dragons!















# #   #   {state, graph}
# #   # end

# #   def process({%{viewport: %{width: w}} = state, graph}, {'NEW_NOTE_COMMAND', contents, buffer_pid: buf_pid}) do
# #     width  = w / 3
# #     height = width
# #     top_left_corner_x = (w/2)-(width/2) # center the box
# #     top_left_corner_y = height / 5
# #     id = {:note, generate_note_buffer_id(state.component_ref), buf_pid}

# #     {:note, note_num, _buf_pid} = id
# #     multi_note_offset = (note_num - 1) * 15

# #     new_graph =
# #       graph
# #       |> GUI.Component.Note.add_to_graph(%{
# #            id: id,
# #            top_left_corner: {top_left_corner_x + multi_note_offset, top_left_corner_y + multi_note_offset},
# #            dimensions: {width, height},
# #            contents: contents
# #          }, id: id)

# #     new_state =
# #       state
# #       |> Map.replace!(:active_buffer, id)
# #       |> Map.replace!(:mode, :edit)

# #     {new_state, new_graph}
# #   end

# #   def process({%{viewport: %{width: w, height: h}} = state, graph}, {'NEW_LIST_BUFFER', data}) do

# #     # state = DataFile.read()
# #     command_buffer = state.buffers |> hd()
# #     # id = {:list, :notes, buf_pid}
# #     id = {:list, :notes}

# #     new_graph =
# #       graph
# #       |> GUI.Component.List.add_to_graph(%{
# #           id: id,
# #           top_left_corner: {0, 0},
# #           # dimensions: {w, h - command_buffer.data.height - 1}, #TODO this does put 1 pixel between the two, do we want that??
# #           dimensions: {w, h - command_buffer.data.height},
# #           contents: data
# #         }, id: id)

# #     new_state =
# #       state
# #       |> Map.replace!(:active_buffer, id)
# #       # |> Map.replace!(:mode, :edit)

# #     {new_state, new_graph}

# #     # ibm_plex_mono = Flamelex.GUI.Initialize.ibm_plex_mono_hash()

# #     # add_notes =
# #     #   fn(graph, notes) ->
# #     #     {graph, _offset_count} =
# #     #       Enum.reduce(notes, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
# #     #         graph =
# #     #           graph
# #     #           |> Scenic.Primitives.group(fn graph ->
# #     #                graph
# #     #                |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
# #     #                |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
# #     #                    translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
# #     #                    font_size: 24, fill: :black)
# #     #              end)


# #     #         {graph, offset_count + 1}
# #     #       end)
# #     #     graph
# #     #   end

# #     # new_graph =
# #     #   graph |> add_notes.(notes)

# #   end

# #   def process({state, _graph}, {'NOTE_INPUT', {:note, _x, _pid} = active_buffer, input}) do
# #     [{{:note, _x, buffer_pid}, component_pid}] =
# #       state.component_ref
# #       |> Enum.filter(fn
# #            {^active_buffer, _pid} ->
# #             true
# #          _else ->
# #             false
# #          end)

# #     Franklin.Buffer.Note.input(buffer_pid, {component_pid, input})
# #     state
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'}) do
# #     find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     |> GUI.Component.Note.move_cursor_to_text_section
# #     state
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, graph}, {:active_buffer, :note, 'CLOSE_NOTE_BUFFER'}) do

# #     # find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     # |> GUI.Component.Note.close_buffer

# #     new_graph =
# #       graph |> Scenic.Graph.delete(active_buffer_id)

# #     #TODO here we can de-link the component

# #     {state, new_graph}
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'}) do
# #     find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     |> GUI.Component.Note.move_cursor_to_title_section
# #     state
# #   end

# #   defp generate_note_buffer_id(component_ref) when is_list(component_ref) do
# #     component_ref
# #     |> Enum.filter(fn
# #          {{:note, _x, _buf_pid}, _pid} ->
# #              true
# #          _else ->
# #              false
# #        end)
# #     |> Enum.count
# #     |> (&(&1 + 1)).()
# #   end
# # end
