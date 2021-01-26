defmodule Flamelex.Fluxux.ReducerBehaviour do
  @moduledoc """
  All Reducer modules use this behaviour - it contains common functionality
  & interfaces for working with Reducers.

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


  defmacro __using__(_params) do
    quote do

      use Flamelex.ProjectAliases
      alias Flamelex.Fluxus.Structs.RadixState


      #REMINDER: including this @behaviour in the __using__ macro here means
      #          that any module which calls `use This.Behaviour.Module`
      #          must implement all the callbacks defined in *this* module
      @behaviour Flamelex.Fluxux.ReducerBehaviour

    end
  end


  @doc """
  If you want custom leader keybindings, put them in this map.
  """
  @callback async_reduce(map(), tuple()) :: :ok | :error

end
