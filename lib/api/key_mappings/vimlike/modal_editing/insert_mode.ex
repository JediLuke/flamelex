defmodule Flamelex.KeyMappings.Vim.InsertMode do
   alias Flamelex.Fluxus.Structs.RadixState
   use ScenicWidgets.ScenicEventsDefinitions

   @ignorable_keys [@shift_space, @meta, @left_ctrl]

   def process(%{editor: %{active_buf: active_buf}}, @escape_key) do
      Flamelex.API.Buffer.modify(active_buf, {:set_mode, {:vim, :normal}})
   end

   # treat key repeats as a press
   def process(radix_state, {:key, {key, @key_held, mods}}) do
      process({:key, {key, @key_pressed, mods}}, radix_state)
   end

   # ignore key-release inputs
   def process(_radix_state, {:key, {_key, @key_released, _mods}}) do
      :ignore
   end

   def process(_radix_state, key) when key in @ignorable_keys do
      :ignore
   end

   def process(_radix_state, {:cursor_button, _details}) do
      :ignore
   end

   # all input not handled above, can be handled as editor input
   def process(_radix_state, key) do
      try do
         QuillEx.UserInputHandler.Editor.process(key, Flamelex.API.Buffer)
      rescue
         FunctionClauseError ->
            Logger.warn "Input: #{inspect key} not handled by #{__MODULE__}..."
            :ignore
      end
   end

end
