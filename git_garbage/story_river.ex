# defmodule Flamelex.GUI.Component.Memex.StoryRiverOld do
#     use Scenic.Component
#     use Flamelex.ProjectAliases
#     require Logger
#     alias Flamelex.GUI.Component.Memex.HyperCard
#     alias Flamelex.GUI.Component.LayoutList

#     def init(scene, params, opts) do
#         Logger.debug "#{__MODULE__} initializing..."
#         Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

#         {:ok, open_tidbits} =
#             GenServer.call(Flamelex.GUI.StageManager.Memex, :get_open_tidbits)

#         new_graph =
#           Scenic.Graph.build()
#           |> LayoutList.add_to_graph(%{
#                 id: :story_layout_list, #TODO lol
#                 frame: params.frame,
#                 # components: calc_component_list(open_tidbits)
#                 components: [],
#                     # %{module: HyperCard, params: hd(open_tidbits), opts: []} #TODO?
#                 layout: :flex_grow,
#                 scroll: true
#           }, id: :story_layout_list) #TODO lol

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#         {:ok, new_scene}
#     end

#     # def calc_component_list([t|rest]) do
#     #     init_list = [{HyperCard, t, _opts = [id: HyperCard.rego(t)]}] #TODO this is where we probs ought to make our own component, havibng data & opts seperate sucks

#     #     calc_component_list(init_list, rest)
#     # end

#     # def calc_component_list(results, []), do: results

#     # def calc_component_list(results, [t|rest]) do
#     #     calc_component_list(results ++ [{HyperCard, t, []}], rest)
#     # end

#     def component(%{module: mod, params: p, opts: o}) do
#         [module: mod, params: p, opts: o]
#     end









#     def handle_cast({:add_tidbit, tidbit}, scene) do
#         IO.puts "RECVd recuqest to add tidbit"
#         # ic tidbit
#         :ok = GenServer.call(Flamelex.GUI.Component.LayoutList, {:add_tidbit, tidbit})
#         {:noreply, scene}
#     end

#     def handle_cast({:clicked_edit_tidbit, title}, scene) do
#         IO.puts "EDITING #{inspect title}" 
#         GenServer.cast(title |> String.to_atom, :edit_mode)
#         {:noreply, scene}
#     end

#     def handle_cast({:clicked_exxxxit_tidbit, title}, scene) do
#         IO.puts "Leaving.... #{inspect title}" 
#         # GenServer.cast(title |> String.to_atom, :edit_mode)
#         GenServer.cast(Flamelex.GUI.Component.LayoutList, {:close_tidbit, title})
#         {:noreply, scene}
#     end





#     # #NOTE - you know, this is really the only thing that changes... all
#     # #       the above is Boilerplate

#     # def render(scene) do
#     #     ##TODO next steps

#     #     # we have the hypercard component - we want to really robustify
#     #     # that component
#     #     #
#     #     # then we want to be able to get the sidebar happening with "recent",
#     #     # "open" etc.
#     #     #
#     #     # then we want to be able to edit TidBits
#     #     #
#     #     # Scrolling doesn't even have to come till like last, we can just
#     #     # flick through left/right
#     #     scene
#     # end

#     # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
#     #     Logger.debug "#{__MODULE__} re-rendering..."
#     #     new_scene = scene
#     #     |> assign(frame: f)
#     #     |> render_push_graph()
        
#     #     {:reply, :ok, new_scene}
#     # end
# end

