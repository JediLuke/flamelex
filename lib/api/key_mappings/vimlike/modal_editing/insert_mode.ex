defmodule Flamelex.KeyMappings.Vim.InsertMode do
   alias Flamelex.Fluxus.Structs.RadixState
   use ScenicWidgets.ScenicEventsDefinitions


   def process(%{editor: %{active_buf: active_buf}}, @escape_key) do
      Flamelex.API.Buffer.modify(active_buf, {:set_mode, {:vim, :normal}})
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


  # def key_def(%{active_buffer: active_buf}, input) do
  #   # when input in @valid_text_input_characters do
  #     #TODO maybe we get cursor 1 coords first, and then can move cursor directly
  #     #     to the new spot, and use that as the input
  #     letter = key2string(input) #TODO it was better before, use patern matching here to extract `letter` here
  #     {:fire_actions, [
  #       # update the buffer text
  #       {:modify_buffer, %{
  #           buffer: active_buf,
  #           details: {:insert, letter, %{coords: {:cursor, 1}}} #TODO why is it always cursor 1?
  #           # update_buffer?: true #TODO kinda crude but lets do it
  #       }},
  #       # move the cursor along 1 character
  #       {:move_cursor, %{
  #           buffer: active_buf,
  #           details: %{cursor_num: 1, instructions: {:right, 1, :column}}
  #       }}
  #     ]}
  # end


  # def key_def(_state, @lowercase_x) do
  #   {:execute_function, fn -> raise "intentionally raising! you pressed little x!!" end}
  # end

end






#TODO move me

# defmodule Flamelex.GUI.InputHandler.InsertMode do
#   @moduledoc false
#   use Flamelex.ProjectAliases
#   use ScenicWidgets.ScenicEventsDefinitions
#   alias Flamelex.Fluxus.Structs.RadixState
#   alias Flamelex.GUI.Control.Input.KeyMapping

#   def handle(%{} = state, input) when input in @valid_command_buffer_inputs do
#     case KeyMapping.lookup(state, input) do
#       :ignore_input ->
#           state |> RadixState.add_to_history(input)
#       {:apply_mfa, {module, function, args}} ->
#           Kernel.apply(module, function, args)
#           state |> RadixState.add_to_history(input)
#     end
#   end





#   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, @enter_key = input) do
#   #   cursor_pos =
#   #     {:gui_component, state.active_buffer}
#   #     |> ProcessRegistry.find!()
#   #     |> GenServer.call(:get_cursor_position)

#   #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

#   #   state |> RadixState.add_to_history(input)
#   # end

#   # def handle_input(%{mode: mode} = state, @escape_key) when mode in [:kommand, :insert] do
#   #   Flamelex.API.CommandBuffer.deactivate()
#   #   Flamelex.FluxusRadix.switch_mode(:normal)
#   #   state |> RadixState.set(mode: :normal)
#   # end

#   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
#   #   cursor_pos =
#   #     {:gui_component, state.active_buffer}
#   #     |> ProcessRegistry.find!()
#   #     |> GenServer.call(:get_cursor_position)


#   #   {:codepoint, {letter, _num}} = input

#   #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

#   #   state |> RadixState.add_to_history(input)
#   # end

#   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
#   #   Logger.debug "received some input whilst in :insert mode"
#   #   state |> RadixState.add_to_history(input)
#   # end

# end
