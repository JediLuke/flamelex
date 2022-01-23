defmodule DevTools do
    require Logger
    
    def widget_workbench do
        Logger.debug "#{__MODULE__} opening the WidgetWorkbench..."
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.DevTools, :open_widget_workbench})
    end
end