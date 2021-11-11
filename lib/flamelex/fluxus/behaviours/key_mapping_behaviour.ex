# defmodule Flamelex.Fluxus.KeyMappingBehaviour do
#   @moduledoc """
#   Defines the interface for a key-mapping.
#   """

#   defmacro __using__(_params) do
#     quote do
#       use Flamelex.ProjectAliases
#       use Flamelex.GUI.ScenicEventsDefinitions
#       alias Flamelex.Fluxus.Structs.RadixState
#       require Logger


#       @behaviour Flamelex.Fluxus.KeyMappingBehaviour


#       # this list of scenic events, we just want to totally ignore as input
#       @list_of_ignorable_events [
#           :viewport_enter,
#           :viewport_exit
#       ]


#       @doc """
#       This function is called by FluxusRadix to handle any user input.

#       It in turn calls some of the functions which the module using this
#       KeyMappingBehaviour has implemented, e.g. keymap/1
#       """
#       # def lookup(_radix_state, {ignorable_event, _coords})
#       #   when ignorable_event in @list_of_ignorable_events do
#       #     :ignore_input
#       # end


#       def lookup(radix_state, input) do
#         try do
#           Logger.debug "#{__MODULE__} looking up input from the keymap"
#           keymap(radix_state, input)
#         rescue
#           e in FunctionClauseError ->
#                   context = %{radix_state: radix_state, input: input}

#                   error_msg = ~s(#{__MODULE__} failed to process some input due to a FunctionClauseError.

#                   #{inspect e}

#                   Most likely this KeyMapping module did not have a function
#                   implemented which pattern-matched on this input.

#                   context: #{inspect context})

#                   Logger.warn error_msg
#                   :ignore_input
#         end
#       end
#     end
#   end


#   @doc """
#   This function returns a map, which contains the direct lookups between
#   keystroke inputs (potentially, pattern-matched on differend RadixState's,
#   but still a one-to-one mapping) and actions.

#   If a key must fire off multiple actions, it can return a list of those
#   actions - but the function itself returns a map.
#   """
#   @callback keymap(map(), map()) :: map() #TODO the first param is a R%RadixState{} typespec

# end
