defmodule Flamelex.Keymaps.Editor do
   use ScenicWidgets.ScenicEventsDefinitions
   use Flamelex.Keymaps.Editor.GlobalBindings
   require Logger


   @valid_inputs @valid_text_input_characters ++ [@escape_key]


   def process(%{root: %{active_app: :editor}, editor: %{buffers: buffers, active_buf: active_buf}} = radix_state, input)
      when input in @valid_inputs do
         buf = buffers |> Enum.find(& &1.id == active_buf)
         case buf.mode do
               {:vim, :normal} ->
                  Logger.debug "-- mode: #{inspect buf.mode}, input: #{inspect input}"
                  Flamelex.KeyMappings.Vim.NormalMode.process(radix_state, input)
               {:vim, :insert} ->
                  Flamelex.KeyMappings.Vim.InsertMode.process(radix_state, input)
               other_mode ->
                  raise "Buffer does not support mode: #{inspect other_mode}"
         end
   end

end