defmodule Flamelex.Fluxus.Reducers.Memex do
    @moduledoc false
    use Flamelex.ProjectAliases
  
    ##NOTE: Steps to add a new piece of functionality:
    #           1) Create a new API function, in an API module
    #           2) Create a reducer function, in a Reducer module <-- You are here.
    def process(%{memex: %{graph: nil}} = radix_state, :open_memex) do
        IO.puts "swapping into :memex..."

        new_memex_graph = Scenic.Graph.build()
        |> ScenicWidgets.TestPattern.add_to_graph(%{})
        # |> Flamelex.GUI.Component.MemexScreen.add_to_graph(%{
        #         frame: Frame.new(radix_state.gui.viewport)
        #     }, id: :memex_screen)

        new_radix_state =
            radix_state
            |> put_in([:root, :active_app], :memex)
            |> put_in([:root, :graph], new_memex_graph)

        {:ok, new_radix_state}
    end


end
  