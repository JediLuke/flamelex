defmodule Flamelex.Keymaps.Desktop do
   use Flamelex.Keymaps.Editor.GlobalBindings
   require Logger


   def process(_radix_state, @leader) do
      Logger.debug " <<-- Leader key pressed -->>"
      :ok
   end

   def process(%{kommander: %{hidden?: false}}, @escape_key) do
      :ok = Flamelex.API.Kommander.hide()
   end

   def process(_radix_state, @escape_key) do
      :ignore
   end

   def process(_radix_state, {:cursor_button, _details}) do
      # NOTE - don't handle mouse events at this level, let lower components e.g. MenuBar handle mouse events
      :ignore
   end


   ## Leader-x keybindings
   ## --------------------


   # open the Kommander with keybinding <leader>k
   def process(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_k) do
      Logger.debug "Opening KommandBuffer..."
      :ok = Flamelex.API.Kommander.show()
   end

   def process(radix_state, key) do
      dbg()
   end

   # open the Memex with keybinding <leader>h
   # def process(@lowercase_h, %{history: %{keystrokes: [@leader|_rest]}} = radix_state) do
   #    :ok = Flamelex.API.Memex.open()
   # end
   
end