defmodule Flamelex.Fluxus.Reducers.Memex do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  
    @app_layer :one

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

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :memex)
        |> put_in([:root, :layers, @app_layer], stashed_memex_graph)

        {:ok, new_radix_state}
    end

    def process(%{memex: %{graph: nil}} = radix_state, :open_memex) do
        Logger.debug "Opening (with no history) the memex..."

        new_memex_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Memex.Layout.add_to_graph(%{
                frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
                state: radix_state.memex
            }, id: :layer_2, theme: radix_state.gui.theme)

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :memex)
        |> put_in([:root, :layers, @app_layer], new_memex_graph)

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
        |> put_in([:root, :layers, @app_layer], stashed_desktop_graph)

        {:ok, new_radix_state}
    end

    def process(%{memex: memex} = radix_state, :new_tidbit) do
        Logger.debug "creating a new TidBit..."
        #TODO here check to make sure no other TidBit is already in Edit mode !!
        #NOTE - we dont truly need to save it yet...
        # {:ok, t} = Memelex.My.Wiki.new(%{title: ""})
        t = Memelex.TidBit.construct(%{title: "", type: "text"})
            |> Map.merge(%{mode: :edit, activate: :title, saved?: false, cursor: 0, volatile?: true})
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], memex.story_river.open_tidbits ++ [t])
        {:ok, new_radix_state}
    end

    def process(%{root: %{active_app: :memex}, memex: %{story_river: %{open_tidbits: currently_open_tidbits_list}}} = radix_state, {:open_tidbit, %Memelex.TidBit{} = t}) do
        Logger.debug "opening TidBit: #{inspect t.title}..."
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], currently_open_tidbits_list ++ [t |> Map.merge(%{mode: :read_only})])
        {:ok, new_radix_state}
    end

    def process(%{root: %{active_app: :memex}} = radix_state, {:open_tidbit, :random}) do
        Logger.debug "opening a random TidBit..."
        process(radix_state, {:open_tidbit, Memelex.My.Wiki.random()})
    end
    
    def process(radix_state, {:edit_tidbit, %{tidbit_uuid: tidbit_uuid}}) do
        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn 
                    %{uuid: ^tidbit_uuid} = tidbit ->
                        tidbit |> Map.merge(%{
                            mode: :edit,
                            cursor: String.length(tidbit.data),
                            activate: :title
                        })
                    other_tidbit ->
                        other_tidbit
                    end)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:discard_changes, %{tidbit_uuid: tidbit_uuid}}) do
        # need to refresh TidBit from DB to discard anything we might
        # have "saved" in temporary memory
        saved_tidbit = Memelex.My.Wiki.find!(%{uuid: tidbit_uuid})

        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn 
                    %{uuid: ^tidbit_uuid} = tidbit ->
                        saved_tidbit |> Map.merge(%{
                            mode: :read_only,
                            saved?: true
                        })
                    other_tidbit ->
                        other_tidbit
                    end)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:switch_mode, :read_only, %{tidbit_uuid: tidbit_uuid}}) do
        new_open_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn 
                    %{uuid: ^tidbit_uuid} = tidbit ->
                        tidbit |> Map.merge(%{
                            mode: :edit,
                            cursor: String.length(tidbit.data),
                            activate: :title
                        })
                    other_tidbit ->
                        other_tidbit
                    end)

        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

        {:ok, new_radix_state}
    end


    #TODO discard - simply re-read in the TidBit from memory & dump our changes

    # def process(radix_state, {:update_tidbit, %{uuid: tidbit_uuid} = new_tidbit}) do
    #     new_open_tidbits_list =
    #         radix_state.memex.story_river.open_tidbits
    #         |> Enum.map(fn 
    #                 %{uuid: ^tidbit_uuid} ->
    #                     new_tidbit
    #                 other_tidbit ->
    #                     other_tidbit
    #                 end)

    #     new_radix_state = radix_state
    #     |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)

    #     {:ok, new_radix_state}
    # end

    def process(radix_state, {:modify_tidbit, %{uuid: t_uuid} = t, %{data: new_data, cursor: new_cursor}}) do
        # update data, move the cursor & mark as not-saved
        updated_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn
                    t_to_modify = %{uuid: ^t_uuid} ->
                        %{t_to_modify|data: new_data, cursor: new_cursor} |> Map.merge(%{saved?: false})
                    not_the_tidbit_were_looking_for ->
                        not_the_tidbit_were_looking_for # no modifications
                end)
        
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], updated_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:modify_tidbit, %{uuid: t_uuid} = t, %{title: new_title, cursor: new_cursor}}) do
        # update data, move the cursor & mark as not-saved
        updated_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn
                    t_to_modify = %{uuid: ^t_uuid} ->
                        %{t_to_modify|title: new_title, cursor: new_cursor} |> Map.merge(%{saved?: false})
                    not_the_tidbit_were_looking_for ->
                        not_the_tidbit_were_looking_for # no modifications
                end)
        
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], updated_tidbits_list)

        {:ok, new_radix_state}
    end

    def process(radix_state, {:modify_tidbit, %{uuid: t_uuid} = t, %{activate: section}}) do
        # update data, move the cursor & mark as not-saved
        updated_tidbits_list =
            radix_state.memex.story_river.open_tidbits
            |> Enum.map(fn
                    t_to_modify = %{uuid: ^t_uuid} ->
                        t_to_modify |> Map.merge(%{activate: section})
                    not_the_tidbit_were_looking_for ->
                        not_the_tidbit_were_looking_for # no modifications
                end)
        
        new_radix_state = radix_state
        |> put_in([:memex, :story_river, :open_tidbits], updated_tidbits_list)

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
                    %{uuid: ^tidbit_uuid, mode: :edit, volatile?: true} = tidbit ->
                        #NOTE: a "volatile_tidbit" is one which only exists inside temporary
                        #      memory inside Flamelex, and hasn't been saved into the Memex proper

                        #TODO case, wha if the tidbit was in errpr, we need to update th RadixStore/TidBit in story river with some kind of error state & msg
                        {:ok, new_tidbit} = Memelex.My.Wiki.new(tidbit)
                        new_tidbit |> Map.merge(%{mode: :read_only, saved?: true, volatile?: false})
                    %{uuid: ^tidbit_uuid, mode: :edit, saved?: false} = tidbit ->
                        Logger.debug "saving tidbit..."
                        {:ok, tidbit} = Memelex.My.Wiki.update(tidbit, tidbit) #NOTE: We have to send a changeset to Wiki.update/2, we just send a map with all the same fields again, maybe we can do better than this one day lol
                        tidbit |> Map.merge(%{mode: :read_only, saved?: true})
                    %{mode: :read_only, saved?: true} = other_tidbit ->
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
    # defp cap_position(%{assigns: %{frame: frame}} = scene, coord) do
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

    # defp calc_acc_height(%{assigns: %{state: %{scroll: %{components: components}}}}) do
    #     do_calc_acc_height(0, components)
    # end

    # defp do_calc_acc_height(acc, []), do: acc

    # defp do_calc_acc_height(acc, [{_id, bounds} = c | rest]) do
    #     # top is less than bottom, because the axis starts in top-left corner
    #     {_left, top, _right, bottom} = bounds
    #     component_height = bottom - top

    #     new_acc = acc + component_height + @spacing_buffer
    #     do_calc_acc_height(new_acc, rest)
    # end

    # defp calc_floor({x, y}, {min_x, min_y}), do: {max(x, min_x), max(y, min_y)}

    # defp calc_ceil({x, y}, {max_x, max_y}), do: {min(x, max_x), min(y, max_y)}

end
  