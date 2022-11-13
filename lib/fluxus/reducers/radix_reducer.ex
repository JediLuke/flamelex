defmodule Flamelex.Fluxus.RadixReducer do
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


   Here we have the function which `reduces` a radix_state and an action.

   Our main way of handling actions is simply to broadcast them on to the
   `:actions` broker, which will forward it to all the main Manager processes
   in turn (GUiManager, BufferManager, AgentManager, etc.)

   The reason for this is, what's going to happen is, say I send a command
   like `open_buffer` to open my journal. We spin up this action handler
   task - say that takes 2 seconds to run for some reason. If I send the
   same action again, another process will spin up. Eventually, they're
   both going to finish, and whoever is getting the results (FluxusRadix)
   is going to get 2 messages, and then have to handle the situation of
   dealing with double-processes of actions (yuck!)

   what we want to do instead is, the reducer broadcasts the message to
   the "actions" channel - all the managers are able to react to this event.
   """


   def process(radix_state, {reducer, action}) when is_atom(reducer) do
      try do
         IO.puts "REDUCER #{inspect reducer} - ACTION #{inspect action}"
         reducer.process(radix_state, action)
      rescue
         e in FunctionClauseError ->
         IO.inspect e
         {:error, "#{__MODULE__} -- Reducer `#{inspect reducer}` could not match action: #{inspect action}"}
      end
   end

end
