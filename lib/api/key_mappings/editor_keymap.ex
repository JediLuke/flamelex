defmodule Flamelex.Keymaps.Editor do
   use ScenicWidgets.ScenicEventsDefinitions
   require Logger

   #TODO we should use a lookup radix_state.editor.config, to find the correct keymap here...

   def process(%{root: %{active_app: :editor}, editor: %{buffers: buffers, active_buf: active_buf}} = radix_state, input) do
      buf = buffers |> Enum.find(& &1.id == active_buf)
      case buf.mode do
         {:vim, :normal} ->
            Logger.debug "-- mode: #{inspect buf.mode}, input: #{inspect input}"
            Flamelex.KeyMappings.Vim.NormalMode.process(radix_state, input)
         {:vim, :insert} ->
            Logger.debug "-- mode: #{inspect buf.mode}, input: #{inspect input}"
            Flamelex.KeyMappings.Vim.InsertMode.process(radix_state, input)
         other_mode ->
            #TODO let it crash! But the raise is pretty useful sometimes...
            raise "#{__MODULE__} does not support mode: #{inspect other_mode}"
      end
   end

end