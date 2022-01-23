defmodule Flamelex.Fluxus.Reducers.DevTools do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  

    def process(radix_state, :open_widget_workbench) do
        Logger.warn "OPEN THE WIGET WORKBENCH"
        :ignore
    end


end
  