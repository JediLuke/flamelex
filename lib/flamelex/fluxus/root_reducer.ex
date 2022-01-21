defmodule Flamelex.Fluxus.RootReducer do
  @moduledoc """
  The RootReducer for all flamelex actions.

  These pure-functions are called by ActionListener, to handle specific
  actions within the application. Every action that gets processed, is
  routed down to the sub-reducers, through this module. Every possible
  action, must also be declared inside this file.
  """


  @memex_actions [
    :open_memex
  ]

  def process(radix_state, action) when action in @memex_actions do
    Flamelex.Fluxus.Reducers.Memex.process(radix_state, action)
  end

  def process(radix_state, action) do
    {:error, "RootReducer bottomed-out! No match was found."}
  end

end
