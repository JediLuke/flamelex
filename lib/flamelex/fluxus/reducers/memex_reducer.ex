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

    def process(%{root: %{active_app: app}, memex: %{graph: nil}} = radix_state, :open_memex) do
        Logger.debug "swapping from app: #{inspect app} to :memex..."

        new_memex_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Memex.Layout.add_to_graph(%{
                frame: Frame.new(radix_state.gui.viewport),
                state: radix_state.memex
            }, id: :memex, theme: radix_state.gui.theme)

        new_radix_state =
            radix_state
            |> put_in([:root, :active_app], :memex)
            |> put_in([:root, :graph], new_memex_graph)

        {:ok, new_radix_state}
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

#   def handle_cast({:open_tidbit, t}, state) do
#     Logger.debug "#{__MODULE__} recv'd msg: {:open_random, #{t.title}}"
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
  