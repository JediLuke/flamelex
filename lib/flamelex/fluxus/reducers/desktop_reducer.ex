defmodule Flamelex.Fluxus.Reducers.Desktop do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  

    #NOTE: It is not the responsibility of this reducer, to stash whatever
    #      graph was for the app that came before it. That should happen
    #      when we call "close" or whatever on the DesktOP?? (But I just know, I will end up calling "show desktop" and want to stash the graph...)
    def process(%{desktop: %{graph: nil}} = radix_state, :show_desktop) do
        Logger.debug "Opening (with no history) the desktop..."

        new_desktop_graph = Scenic.Graph.build()
        |> ScenicWidgets.TestPattern.add_to_graph(%{})
        |> Scenic.Primitives.text("This is the Desktop!", t: {140, 150})

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :desktop)
        |> put_in([:root, :graph], new_desktop_graph)

        {:ok, new_radix_state}
    end

end
  