defmodule Flamelex.Keymaps.Kommander do
   use ScenicWidgets.ScenicEventsDefinitions

   @ignorable_keys [@shift_space, @left_shift, @meta, @left_ctrl]

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

   def process(_radix_state, @escape_key) do
      Flamelex.API.Kommander.clear()
      Flamelex.API.Kommander.hide()
   end

   def process(_radix_state, @enter_key) do
      # NOTE - `@enter_key` is a member of `@valid_text_input_characters` so we need to match here first
      Flamelex.API.Kommander.execute()
      Flamelex.API.Kommander.reset()
   end

   def process(%{kommander: %{hidden?: false, buffer: %{mode: :edit} = k_buf}}, key)
      when not is_nil(k_buf) and key in @valid_text_input_characters do
         Flamelex.API.Kommander.modify({:insert, key |> key2string(), :at_cursor})
   end

   def process(_radix_state, @backspace_key) do
      Flamelex.API.Kommander.modify({:backspace, 1, :at_cursor})
   end

   def process(_radix_state, key) when key in @arrow_keys do

      # REMINDER: these tuples are in the form `{line, col}`
      delta = case key do
         @left_arrow ->
            {0, -1}
         @up_arrow ->
            {-1, 0}
         @right_arrow ->
            {0, 1}
         @down_arrow ->
            {1, 0}
      end

      Flamelex.API.Kommander.move_cursor(delta)
   end

   def process(radix_state, key) do
      IO.puts "#{__MODULE__} failed to process input: #{inspect key}"
      dbg()
   end


end



#   def handle(%{} = state, input) when input in @valid_command_buffer_inputs do
#     case KeyMapping.lookup(state, input) do
#       :ignore_input ->
#           state |> RadixState.add_to_history(input)
#       {:apply_mfa, {module, function, args}} ->
#           Kernel.apply(module, function, args)
#           state |> RadixState.add_to_history(input)
#     end
#   end

# defmodule Flamelex.KeyMappings.Vim.KommandMode do
#     alias Flamelex.Fluxus.Structs.RadixState
#     use ScenicWidgets.ScenicEventsDefinitions
#     require Logger
  
  
#     def keymap(%{mode: :kommand}, @escape_key) do
#       # {:fire_action, {:switch_mode, :normal}} #TODO this doesn't de-activate the command buffer (unless we get gui broadcast working...)
#       {:fire_actions, [
#         {KommandBuffer, :hide}, #TOD this should be de-activate, so it clears the buffer
#         {:switch_mode, :normal}
#       ]}
  
#       # GenServer.cast(Flamelex.Buffer.KommandBuffer, :execute)
#       # GenServer.cast(Flamelex.Buffer.KommandBuffer, :clear_and_hide)
#     end
  
  
#     def keymap(%{mode: :kommand}, @enter_key) do
#       {:fire_action, {KommandBuffer, :execute}}
#       # GenServer.cast(Flamelex.Buffer.KommandBuffer, :execute)
#       # GenServer.cast(Flamelex.Buffer.KommandBuffer, :hide)
#     end
  
#     def keymap(%{mode: :kommand}, @backspace_key) do
#       # GenServer.cast(KommandBuffer, {:backspace, 1})
#       GenServer.cast(KommandBuffer, {:modify, %{backspace: {:cursor, 1}}}) #TODO hard-coded 1, again!
#     end
  
  
#     def keymap(%{mode: :kommand}, input)
#     #TODO maybe this should be an action...
#       when input in @valid_text_input_characters do
#         Logger.debug "detected a valid character as input in :kommand mode: #{inspect input}"
#         GenServer.cast(KommandBuffer, {:input, input})
#     end
  
  
  
  
#     # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @left_shift_and_space_bar) do
#     #   Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
#     #   state
#     # end
  
#     # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @space_bar = input) do
#     #   Scene.action({'COMMAND_BUFFER_INPUT', input})
#     #   state |> add_to_input_history(input)
#     # end
#   end
  