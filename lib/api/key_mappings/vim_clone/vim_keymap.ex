defmodule Flamelex.API.KeyMappings.VimClone do
  @moduledoc """
  Implements the Vim keybindings for editing text inside flamelex.

  https://hea-www.harvard.edu/~fine/Tech/vi.html
  """
  use Flamelex.Fluxux.KeyMappingBehaviour
  alias Flamelex.API.KeyMappings.VimClone.{NormalMode, KommandMode,
                                           InsertMode, LeaderBindings}


  # this is our vim leader
  def leader, do: @space_bar


  def keymap(%RadixState{mode: :normal} = state, input) do
    if last_keystroke_was_leader?(state) do
      LeaderBindings.keymap(state, input)
    else
      NormalMode.keymap(state, input)
    end
  end


  def keymap(%RadixState{mode: :kommand} = state, input) do
    KommandMode.keymap(state, input)
  end


  def keymap(%RadixState{mode: :insert} = state, input) do
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
