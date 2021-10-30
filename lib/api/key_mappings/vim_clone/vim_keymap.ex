defmodule Flamelex.API.KeyMappings.VimClone do
  @moduledoc """
  Implements the Vim keybindings for editing text inside flamelex.

  https://hea-www.harvard.edu/~fine/Tech/vi.html
  """
  use Flamelex.Fluxux.KeyMappingBehaviour
  alias Flamelex.API.KeyMappings.VimClone.{NormalMode, KommandMode,
                                           InsertMode, LeaderBindings}
  require Logger


  # this is our vim leader
  def leader, do: @space_bar


  def keymap(%RadixState{mode: :normal} = state, input) do
    if last_keystroke_was_leader?(state) do
      Logger.debug "doing a LeaderBindings lookup on: #{inspect input}"
      LeaderBindings.keymap(state, input)
    else
      Logger.debug "doing a NormalMode lookup on #{inspect input}"
      NormalMode.keymap(state, input)
    end
  end


  def keymap(%RadixState{mode: :kommand} = state, input) do
    KommandMode.keymap(state, input)
  end


  def keymap(%RadixState{mode: :insert} = state, input) do
    Logger.debug "#{__MODULE__} received input: #{inspect input}, routing it to InsertMode..."
    InsertMode.keymap(state, input)
  end


  def keymap(state, input) do
    context = %{state: state, input: input}
    raise "failed to pattern-match on a known :mode in the RadixState. #{inspect context}"
  end


  # returns true if the last key was pressed was the leader key
  def last_keystroke_was_leader?(radix_state) do
    leader() != :not_defined
      and
    radix_state |> RadixState.last_keystroke() == leader()
  end
end
