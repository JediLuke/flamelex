defmodule Flamelex.Fluxus.Reducers.Memex do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  
    ##NOTE: Steps to add a new piece of functionality:
    #           1) Create a new API function, in an API module
    #           2) Create a reducer function, in a Reducer module <-- You are here.
    #           3) Update related components to handle potential new states (just changing between known states should work already, assuming your components know how to render the new state)

    def process(%{root: %{active_app: :memex}} = radix_state, :open_memex) do
        Logger.debug "ignoring a command to open the memex, the memex is already active"
        :ignore
    end

    def process(%{root: %{active_app: active_app}, memex: %{graph: %Scenic.Graph{} = stashed_memex_graph}} = radix_state, :open_memex) when active_app != :memex do
        Logger.debug "swapping from `#{inspect active_app}` to `:memex` (with history)..."
        Logger.warn "here, we ought to be stashign the previous graph into something..."

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :memex)
        |> put_in([:root, :graph], stashed_memex_graph)

        {:ok, new_radix_state}
    end

    def process(%{memex: %{graph: nil}} = radix_state, :open_memex) do
        Logger.debug "Opening (with no history) the memex..."

        new_memex_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Memex.Layout.add_to_graph(%{
                frame: Frame.new(radix_state.gui.viewport),
                state: radix_state.memex
            }, id: :memex, theme: radix_state.gui.theme)

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :memex)
        |> put_in([:root, :graph], new_memex_graph)

        {:ok, new_radix_state}
    end

    def process(%{root: %{active_app: :memex}, desktop: %{graph: nil}} = radix_state, :close_memex) do
        Logger.debug "swapping from `:memex` to `:desktop`, but we need to render a new desktop..."
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Desktop, :show_desktop})
        :ignore
    end

    def process(%{root: %{active_app: :memex}, desktop: %{graph: %Scenic.Graph{} = stashed_desktop_graph}} = radix_state, :close_memex) do
        Logger.debug "swapping from `:memex` to `:desktop`..."

        new_radix_state = radix_state
        |> put_in([:memex, :graph], radix_state.root.graph) # stash the current graph for the memex
        |> put_in([:root, :active_app], :desktop)
        |> put_in([:root, :graph], stashed_desktop_graph)

        {:ok, new_radix_state}
    end

    def process(%{root: %{active_app: :memex}, memex: %{story_river: %{open_tidbits: currently_open_tidbits_list}}} = radix_state, {:open_tidbit, %Memelex.TidBit{} = t}) do
        Logger.debug "opening TidBit: #{inspect t.title}..."
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], currently_open_tidbits_list ++ [t])
        {:ok, new_radix_state}
    end

    def process(%{root: %{active_app: :memex}} = radix_state, {:open_tidbit, :random}) do
        Logger.debug "opening a random TidBit..."
        process(radix_state, {:open_tidbit, Memelex.My.Wiki.random()})
    end

    def process(radix_state, {:switch_mode, :edit, %{tidbit_uuid: tidbit_uuid}}) do
        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn 
                    %{uuid: ^tidbit_uuid} = tidbit ->
                        tidbit |> Map.merge(%{edit_mode?: true})
                    other_tidbit ->
                        other_tidbit
                    end)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:close_tidbit, %{tidbit_uuid: tidbit_uuid}}) do
        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.reject(& &1.uuid == tidbit_uuid)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:save_tidbit, %{tidbit_uuid: tidbit_uuid}}) do
        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn 
                    %{uuid: ^tidbit_uuid} = tidbit ->
                        tidbit |> Map.merge(%{edit_mode?: false})
                        #TODO really save the TidBit in the Memex
                    other_tidbit ->
                        other_tidbit
                    end)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:scroll, {_x, y_scroll}, Flamelex.GUI.Component.Memex.StoryRiver}) do

        current_scroll = radix_state.memex.story_river.scroll.accumulator
        fast_scroll = {0, 3*y_scroll}
        # new_cumulative_scroll = cap_position(scene, Scenic.Math.Vector2.add(current_scroll, fast_scroll))
        new_cumulative_scroll = Scenic.Math.Vector2.add(current_scroll, fast_scroll)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :scroll, :accumulator], new_cumulative_scroll)

        {:ok, new_radix_state}
    end



    # # <3 @vacarsu
    # def cap_position(%{assigns: %{frame: frame}} = scene, coord) do
    #     # NOTE: We must keep track of components, because one could
    #     #      get yanked out the middle.
    #     height = calc_acc_height(scene)
    #     # height = scene.assigns.state.scroll.acc_length
    #     if height > frame.dimensions.height do
    #         coord
    #         |> calc_floor({0, -height + frame.dimensions.height / 2})
    #         |> calc_ceil({0, 0})
    #     else
    #         coord
    #         |> calc_floor(@min_position_cap)
    #         |> calc_ceil(@min_position_cap)
    #     end
    # end

    # def calc_acc_height(%{assigns: %{state: %{scroll: %{components: components}}}}) do
    #     do_calc_acc_height(0, components)
    # end

    # def do_calc_acc_height(acc, []), do: acc

    # def do_calc_acc_height(acc, [{_id, bounds} = c | rest]) do
    #     # top is less than bottom, because the axis starts in top-left corner
    #     {_left, top, _right, bottom} = bounds
    #     component_height = bottom - top

    #     new_acc = acc + component_height + @spacing_buffer
    #     do_calc_acc_height(new_acc, rest)
    # end

    # defp calc_floor({x, y}, {min_x, min_y}), do: {max(x, min_x), max(y, min_y)}

    # defp calc_ceil({x, y}, {max_x, max_y}), do: {min(x, max_x), min(y, max_y)}

end
  