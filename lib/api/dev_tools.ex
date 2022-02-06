defmodule DevTools do
    require Logger
    
    def widget_workbench do
        Logger.debug "#{__MODULE__} opening the WidgetWorkbench..."
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.DevTools, :open_widget_workbench})
    end
end

# defmodule Flamelex.API.Mode do
#     @moduledoc """
#     Gives a user full control over all things related to the input mode
#     of the GUI.
  
#     ## A short note on `modes`
  
#     There are several famous & intelligent engineers who are strongly opposed
#     to the concept of modes - and I respect their opinion; it is not without
#     merit. Modes are complicated and unintuitive to the user. They require
#     training and practice to use effectively - when that is achieved though,
#     it has been my experience in using vim at least, that a very satisfying,
#     intuitive (or perhaps just, performed in the "back of my mind", not the
#     same part that likes to think about what I'm programming), efficient &
#     economical form of Human-Computer interaction. So yeah, I think if people
#     want to maximize their bandwidth when interacting with computers, I think
#     it's worth learning a modal editor.
  
#     In a future life, when we're all Start Fleet officers, we can continue
#     the discussion, about whether or not modes would be a good/bad idea in
#     LCARS.
  
#     In Flamelex, I treat modes as a strictly user-input side concern. The
#     mode changes what happens when you press the buttons. It changes how
#     some things are rendered. However, nothing "internal" to Flamelex ever
#     changes. There is no concept of a mode in the `Buffer` API, for example.
#     Changing the mode, doesn't affect the result of any of those underlying
#     functions, there is no internal state in that part of the application
#     which understands modes.
  
#     Right now, modes are global. Insert mode will put the active Buffer, into
#     insert mode. It might be prudent at some point to scope modes to active
#     (or not?) Buffers/Windows.
#     """
#     use Flamelex.ProjectAliases
  
  
#     @doc """
#     Returns the current input mode.
#     """
#     def current_mode do
#       radix = GenServer.call(Flamelex.FluxusRadix, :get_state)
#       radix.mode
#     end
  
  
#     def switch_mode(m) do
#       Flamelex.FluxusRadix
#       |> GenServer.cast({:action, {:switch_mode, m}})
#     end
#   end
  