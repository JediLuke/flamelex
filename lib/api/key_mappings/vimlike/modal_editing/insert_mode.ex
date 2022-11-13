defmodule Flamelex.KeyMappings.Vim.InsertMode do
   alias Flamelex.Fluxus.Structs.RadixState
   use ScenicWidgets.ScenicEventsDefinitions

   @ignorable_keys [@shift_space, @meta, @left_ctrl]

   # These are convenience bindings to make the code more readable when moving cursors
   @left_one_column {0, -1}
   @up_one_row {-1, 0}
   @right_one_column {0, 1}
   @down_one_row {1, 0}

   def process(%{editor: %{active_buf: active_buf}}, @escape_key) do
      Flamelex.API.Buffer.modify(active_buf, {:set_mode, {:vim, :normal}})
      # NOTE - we have to go back one column because insert & normal mode don't align on what column they're operating on...
      Flamelex.API.Buffer.move_cursor(@left_one_column)
   end

   # treat key repeats as a press
   def process(radix_state, {:key, {key, @key_held, mods}}) do
      process(radix_state, {:key, {key, @key_pressed, mods}})
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
