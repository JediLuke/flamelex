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

   # If we try to open a TidBit and we're already in editor mode, don't switch to Memex mode
   def process(%{root: %{active_app: active_app}} = radix_state, {
      Memelex.Fluxus.Reducers.TidbitReducer,
      {:open_tidbit, %{type: ["external", "textfile"], data: %{"filepath" => filepath}} = tidbit}
   }) when active_app in [:desktop, :editor] do
      QuillEx.Reducers.BufferReducer.process(radix_state, {:open_buffer, %{file: filepath, mode: {:vim, :normal}}})
   end

   def process(radix_state, {:widget_wkb, :open}) do
      {:ok, radix_state |> open_widget_wkb()}
   end

   def process(radix_state, {reducer, action}) when is_atom(reducer) do

      # Instead of try catch, look in the module, see if there's a function called that.

      # That could be cool, if we make all actions an actual function in the processor??

      # If that fails/doesn't work, we want to look up custom keymaps in the my_modz.ex

      try do
         reducer.process(radix_state, action)
      rescue
         e in FunctionClauseError ->
         IO.inspect e
         {:error, "#{__MODULE__} -- Reducer `#{inspect reducer}` could not match action: #{inspect action}"}
      end
   end


   def process(radix_state, :open_memex) do
      new_radix_state = 
         radix_state
         |> put_in([:root, :active_app], :memex)

      {:ok, new_radix_state}
   end




   #TODO here, we should have a module of transformations for the radix state!
   # Make RadixState a struct!?!?
   defp open_widget_wkb(radix_state) do
      Flamelex.Fluxus.Structs.RadixState.mutate(radix_state, :open_widget_wkb)
   end

end
