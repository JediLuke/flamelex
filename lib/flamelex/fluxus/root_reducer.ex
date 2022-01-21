defmodule Flamelex.Fluxus.RootReducer do
  @moduledoc """
  The RootReducer for all flamelex actions.

  These pure-functions are called by ActionListener, to handle specific
  actions within the application. Every action that gets processed, is
  routed down to the sub-reducers, through this module. Every possible
  action, must also be declared inside this file.


  A reducer is a function that determines changes to an application's state.

  All the reducers in Flamelex.Fluxus (and this includes both action
  handlers, and user-input handlers) work the same way - they take in
  the application state, & an action, & return an updated state. They
  may also fire off side-effects along the way, including further actions.

  ```
  A reducer is a function that determines changes to an application's state.
  It uses the action it receives to determine this change. We have tools,
  like Redux, that help manage an application's state changes in a single
  store so that they behave consistently.
  ```
  https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

  """
  require Logger


  @memex_actions [
    :open_memex
  ]

  def process(%{memex: %{active?: false}}, _action) do
    Logger.warn "#{__MODULE__} ignoring a memex action, because the memex is set to `inactive`"
    :ignore
  end

  def process(%{memex: %{active?: true}} = radix_state, action) when action in @memex_actions do
    Flamelex.Fluxus.Reducers.Memex.process(radix_state, action)
  end

  def process(radix_state, action) do
    {:error, "RootReducer bottomed-out! No match was found."}
  end

end
