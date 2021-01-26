defmodule Flamelex.Fluxus do
  @moduledoc """
  Flamelex.Fluxus implements the `flux` architecture pattern, of React.js
  fame, in Elixir/Scenic. This module provides the interface to that
  functionality.

  ### background

  https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

  ### prior art

  https://medium.com/grandcentrix/state-management-with-phoenix-liveview-and-liveex-f53f8f1ec4d7
  """

  @doc """
  This function enables us to fire actions off which enact changes, at
  the FluxusRadix level, but which aren't stricly responses to user input.
  """
  def fire_action(a) do
    GenServer.cast(Flamelex.FluxusRadix, {:action, a})
  end

  #NOTE: If the process dispatching this action requires a callback, that's possible
  # def fire_action(a, await_callback?: true) do
  #   GenServer.cast(Flamelex.FluxusRadix, {:action, a, callback_pid: self()})
  #   receive do
  #     callback ->
  #       callback
  #   after
  #     @action_callback_timeout ->
  #       {:error, "timed out waiting for the action to callback"}
  #   end
  # end


  @doc """
  This function is called to channel all user input, e.g. keypresses,
  through the FluxusRadix, where they can be converted into actions.

  This function handles user input. All input from the entire GUI gets
  routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

  We use the RadixState (which includes global variables such as which
  mode we are in, the input history [to allow chaining of keystrokes\] etc),
  as well as the input itself, to compute the new state.

  The effect of most user input will be either to ignore it, or to dispatch
  an action - this is achieved by sending a new msg to the FluxusRadix, which
  will in turn be handled by spinning up a new Task process to handle it.
  """
  def handle_user_input(ii) do
    GenServer.cast(Flamelex.FluxusRadix, {:user_input, ii})
  end
end
