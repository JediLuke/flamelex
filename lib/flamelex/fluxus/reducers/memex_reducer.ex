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
            }, id: :memex)

        new_radix_state =
            radix_state
            |> put_in([:root, :active_app], :memex)
            |> put_in([:root, :graph], new_memex_graph)

        {:ok, new_radix_state}
    end


end
  