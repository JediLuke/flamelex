# defmodule Flamelex.GUI.TextFile.Layout do
#     use Scenic.Component
#     use Flamelex.ProjectAliases
#     require Logger
#     alias QuillEx.GUI.Components.Editor, as: QuillExEditor


#     #TODO the editor layour itself shouldn't need a buffer to render else what happens if we close it??
#     def validate(%{buffer_id: {:buffer, _id}, frame: %Frame{} = _fr, font: _fnt, state: _s} = data) do
#         #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
#         {:ok, data}
#     end

#     def init(init_scene, args, opts) do
#         Logger.debug "#{__MODULE__} initializing..."
    
#         # #NOTE: This component doesn't need to subscribe to RadixState changes

#         # #TODO here - use a WindowArrangement of {:columns, [1,2,1]}
#         # init_graph = Scenic.Graph.build()
#         # #TODO make this a ScenicWidgets.ExpandableNavBar
#         # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: left_quadrant(args.frame), color: :alice_blue})
#         # |> Memex.StoryRiver.add_to_graph(%{
#         #         frame: mid_section(args.frame),
#         #         state: args.state.story_river})
#         # |> Memex.SideBar.add_to_graph(%{
#         #         frame: right_quadrant(args.frame),
#         #         state: args.state.sidebar})
#         pad_mode = case args.state.mode do
#             {:vim, m} -> m
#         end

#         #TODO here need to get all the buffer details, probably from radix_state??
#         init_graph = Scenic.Graph.build()
#         # |> Scenic.Primitives.rect(args.frame.size, translate: args.frame.pin, fill: :purple) #TODO remove this one I know I am lining up buffers correctly
#         |> ScenicWidgets.TextPad.add_to_graph(%{
#             id: {:text_pad, args.buffer_id},
#             frame: args.frame,
#             text: args.state.data,
#             mode: pad_mode,
#             margin: %{left: 2, top: 0, bottom: 0, right: 2},
#             format_opts: %{
#                 alignment: :left,
#                 wrap_opts: :no_wrap,
#                 scroll_opts: :all_directions,
#             },
#             font: args.font |> Map.merge(%{size: 24}) #TODO take this from radix_State I guess
#         }, id: {:text_pad, args.buffer_id})

#         new_scene = init_scene
#         |> assign(buffer_id: args.buffer_id)
#         |> assign(graph: init_graph)
#         |> assign(frame: args.frame)
#         |> assign(state: args.state)
#         |> assign(font: args.font |> Map.merge(%{size: 24}))
#         |> push_graph(init_graph)

#         # cast_children(scene, :start_caret)
#         Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)
  
#         {:ok, new_scene}
#     end

#     def calc_body_frame(hypercard_frame) do
# 		#REMINDER: Because we render this from within the group (which is
# 		#		   already getting translated, we only need be concerned
# 		#		   here with the _relative_ offset from the group. Or
# 		#		   in other words, this is all referenced off the top-left
# 		#		   corner of the HyperCard, not the top-left corner
# 		#		   of the screen.
# 		Frame.new(pin: {200, 225},
# 			      size: {500, 500})
# 	end

#     # def left_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
#     #     Frame.new(top_left: {x, y}, dimensions: {w/4, h})
#     # end

#     # def mid_section(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
#     #     one_quarter_page_width = w/4
#     #     Frame.new(top_left: {x+one_quarter_page_width, y}, dimensions: {w/2, h})
#     # end

#     # def right_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
#     #     Frame.new(top_left: {x+((3/4)*w), y}, dimensions: {w/4, h})
#     # end

#     # def handle_info({:radix_state_change, %{kommander: new_state}}, %{assigns: %{state: current_state}} = scene)
#     # when new_state != current_state do

#     # def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do

#     #     this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
#     #     [{^this_layer, radix_layer_graph}] =
#     #         layer_list |> Enum.filter(fn {layer, graph} -> layer == scene.assigns.id end)
    
#     #     if scene.assigns.graph != radix_layer_graph do
#     #         Logger.debug "#{__MODULE__} Layer_ #{inspect scene.assigns.id} changed, re-drawing the RootScene..."
            
#     #         new_scene = scene
#     #         |> assign(graph: radix_layer_graph)
#     #         |> push_graph(radix_layer_graph)
    
#     #         {:noreply, new_scene}
#     #     else
#     #         Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
#     #         {:noreply, scene}
#     #     end
#     # end

#     def handle_info({:radix_state_change, %{editor: %{buffers: []}}}, scene) do
#         #TODO do a better job here lol
#         # new_state = 

#         new_graph = Scenic.Graph.build()

#         new_scene = scene
#         |> assign(buffer_id: nil)
#         |> assign(graph: new_graph)
#         # |> assign(frame: args.frame)
#         # |> assign(state: args.state)
#         |> push_graph(new_graph)

#         {:noreply, new_scene}
#     end

#     def handle_info({:radix_state_change, %{editor: %{buffers: buffers}}}, %{assigns: %{buffer_id: this_buf_id}} = scene) do
#         this_buf = buffers |> Enum.find(& &1.id == this_buf_id)
#         # if this_buf.graph != scene.assigns.graph do
#         #     Logger.debug "Buffer `#{inspect this_buf.id}` has changed, updating it."

#         pad_mode = case this_buf.mode do
#             {:vim, m} -> m
#         end

#         # ScenicWidgets.TextPad.redraw({:text_pad, this_buf.id}, %{

#         # })
            
#         #     new_scene = scene
#         #     |> assign(graph: this_buf.graph)
#         #     |> assign(state: this_buf)
#         #     |> push_graph(this_buf.graph)
#         # scene |> Scenic.Scene.update_child({:text_pad, this_buf.id}, %{
#         #     text: this_buf.data,
#         #     cursor: %{
#         #         line: 1,
#         #         col: 2,
#         #         mode: :normal
#         #     },
#         #     scroll_acc: {0, 0}
#         # })


#         #     {:noreply, new_scene}
#         # else
#         #     Logger.debug "Buffer `#{inspect this_buf.id}` not updating, nothing has changed..."
#         #     {:noreply, scene}
#         # end
#           #TODO maybe send it a list of lines instead? Do the rope calc here??
#           {:ok, [pid]} = child(scene, {:text_pad, this_buf.id})

#         #   # NOTE: We have to do data & cursor at the same time, since we need to make sure
#         #   # data is updated before thec cursor is (since we use the full  text to calculate
#         #   # the position of the cursor) and this can't be guaranteed merely by sending msgs
#         #   # GenServer.cast(pid, {:redraw, %{data: active_buffer.data}})
#         #   # GenServer.cast(pid, {:redraw, %{cursor: hd(active_buffer.cursors)}})
#           GenServer.cast(pid, {:redraw, %{data: this_buf.data, cursor: hd(this_buf.cursors) |> Map.merge(%{mode: pad_mode})}})
#         #   GenServer.cast(pid, {:redraw, %{scroll_acc: this_buf.scroll_acc}})

#         {:noreply, scene}
#     end

#     def handle_cast({:scroll_limits, %{inner: %{width: _w, height: _h}, frame: _f} = new_scroll_state}, scene) do
#         IO.puts "Just.... dont"
#         # # update the RadixStore, without broadcasting the changes,
#         # # so we can keep accurate calculations for scrolling
#         # QuillEx.RadixStore.get()
#         # |> QuillEx.RadixState.change_editor_scroll_state(new_scroll_state)
#         # |> QuillEx.RadixStore.put(:without_broadcast)
    
#         {:noreply, scene}
#       end
# end