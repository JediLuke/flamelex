# defmodule Flamelex.Fluxus.Reducers.Kommand do
#   @moduledoc """
#   Helper functions, called by the `RootReducer`, to process actions related
#   to the Kommander.
#   """
#   use Flamelex.ProjectAliases
#   require Logger


#   alias Flamelex.Fluxus.Reducers.Mode, as: ModeReducer


#   #REMINDER: Don't be tempted to use an alias like
#   #          alias Flamelex.Buffer.KommandBuffer, it will only break
#   #          stuff (because I use KommandBuffer explicitely as an atom)


#   def handle(radix_state, {:action, {KommandBuffer, action}}) do
#     #TODO even though I (think?) at this point, each Reduction being
#     # passed through RootRecuder, and then in turn to here, is already
#     # in it's own process - it might be a good idea to add another
#     # Supervisor anyway :P
#     radix_state |> reduce(action)
#   end


#   # private functions


#   defp reduce(radix_state, :show) do
#     Logger.debug "showing the KommandBuffer..."

#     # update the GUI
#     #TODO this should be checking if the process exists
#     {:gui_component, KommandBuffer}
#     |> ProcessRegistry.find!()
#     |> GenServer.cast(:show)

#     radix_state |> switch_mode(:kommand)
#   end

#   defp reduce(radix_state, :hide) do
#     Logger.debug "hiding the KommandBuffer..."

#     # update the GUI
#     #TODO this should be checking if the process exists
#     {:gui_component, KommandBuffer}
#     |> ProcessRegistry.find!()
#     |> GenServer.cast(:hide)

#     radix_state |> switch_mode(:normal)
#   end

#   defp reduce(radix_state, :execute) do
#     Logger.debug "KommandReducer received action saying :execute..."
#     GenServer.cast(KommandBuffer, :execute)

#     #NOTE: If successful, the KommandBuffer will, in turn, call us (FluxusRadix)
#     #      back, telling us to switch back to normal mode.
#     #      Return the state unchanged.
#     radix_state |> switch_mode(:normal)
#   end

#   defp reduce(_radix_state, {:action, {KommandBuffer, x}}) do
#     Logger.warn "KommandBuffer received an unmatched action: #{inspect x} - forwarding to KommandBuffer..."
#     GenServer.cast(KommandBuffer, x)
#   end

#   #NOTE: This is just an aesthetic function, to make sure all mode-changes
#   #      look nice in the code, but are still channeled through the ModeReducer
#   defp switch_mode(radix_state, new_mode) do
#     ModeReducer.handle(radix_state, {:action, {:switch_mode, new_mode}})
#   end
# end
