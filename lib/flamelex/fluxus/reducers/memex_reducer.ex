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






    #   def handle_cast(:open_random_tidbit, state) do
#         # t = Memex.random()
#     # # GenServer.cast(:hypercard, {:new_tidbit, t})
#     # GenServer.cast(Flamelex.GUI.Component.Memex.HyperCard, {:new_tidbit, t})
#     Logger.debug "#{__MODULE__} recv'd msg: :open_random_tidbit"
#     t = Memex.My.Wiki.list |> Enum.random()
#     new_state = %{state|open: state.open ++ [t]}
#     GenServer.cast(Flamelex.GUI.Component.Memex.StoryRiver, {:add_tidbit, t})
#     {:noreply, new_state}
#   end


#   def handle_call(:get_open_tidbits, _from, %{open: []} = state) do
#     Logger.warn "Dont wanna open empty Memex yet lol, just render a rando..."
#     #TODO fix the bug vacarsu found here
#     case Memex.My.Wiki.list() do
#       [] ->
#         Logger.warn "WE SHOULD just always make at least one thing in the Meme..."
#         {:reply, {:ok, []}, state}
#       [_t|_rest] ->
#         rando = Memex.My.Wiki.list |> Enum.random()
#         {:reply, {:ok, [rando]}, %{state|open: [rando]}}
#     end
#   end



end
  