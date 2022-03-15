# defmodule Flamelex.API.KeyMappings.Vim do
#   @moduledoc """
#   Implements the Vim keybindings for editing text inside flamelex.

#   https://hea-www.harvard.edu/~fine/Tech/vi.html
#   """
#   # use Flamelex.Fluxus.KeyMappingBehaviour
#   alias Flamelex.API.KeyMappings.Vim.{NormalMode, KommandMode,
#                                            InsertMode, LeaderBindings}
#   use Flamelex.ProjectAliases
#   use ScenicWidgets.ScenicEventsDefinitions
#   alias Flamelex.Fluxus.Structs.RadixState
#   require Logger



#   # this is our vim leader
#   def leader, do: @space_bar

#   def lookup(radix_state, input) do
#     try do
#       Logger.debug "#{__MODULE__} looking up input from the keymap"
#       keymap(radix_state, input)
#     rescue
#       e in FunctionClauseError ->
#               context = %{radix_state: radix_state, input: input}

#               error_msg = ~s(#{__MODULE__} failed to process some input due to a FunctionClauseError.

#               #{inspect e}

#               Most likely this KeyMapping module did not have a function
#               implemented which pattern-matched on this input.

#               context: #{inspect context})

#               Logger.warn error_msg
#               :ignore_input
#     end
#   end

#   def keymap(%{mode: :normal} = state, input) do
#     if last_keystroke_was_leader?(state) do
#       #Logger.debug "doing a LeaderBindings lookup on: #{inspect input}"
#       LeaderBindings.keymap(state, input)
#     else
#       #Logger.debug "doing a NormalMode lookup on #{inspect input}"
#       NormalMode.keymap(state, input)
#     end
#   end



#   def keymap(%{mode: :insert} = state, input) do
#     #Logger.debug "#{__MODULE__} received input: #{inspect input}, routing it to InsertMode..."
#     InsertMode.keymap(state, input)
#   end


#   # def keymap(state, input) do
#   #   context = %{state: state, input: input}
#   #   raise "failed to pattern-match on a known :mode in the RadixState. #{inspect context.state.mode}"
#   # end


#   # returns true if the last key was pressed was the leader key
#   def last_keystroke_was_leader?(radix_state) do
#     leader() != :not_defined
#       and
#     radix_state |> RadixState.last_keystroke() == leader()
#   end
# end
