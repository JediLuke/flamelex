defmodule Flamelex.API.KeyMappings.VimClone.InsertMode do
  alias Flamelex.Fluxus.Structs.RadixState
  use ScenicWidgets.ScenicEventsDefinitions


  # this is the function which gets called externally
  def keymap(%{mode: :insert, active_buffer: b} = state, input) when not is_nil(b) do
    key_def(state, input)
  end

  def key_def(_state, @escape_key) do
    {:fire_action, {:switch_mode, :normal}}
  end

  def key_def(%{active_buffer: active_buf}, @backspace_key) do
    {:fire_action, {:modify_buffer, %{
        buffer: active_buf,
        details: %{backspace: {:cursor, 1}}, #TODO why is it always cursor 1?
    }}}
  end


  def key_def(%{active_buffer: active_buf}, input) do
    # when input in @valid_text_input_characters do
      #TODO maybe we get cursor 1 coords first, and then can move cursor directly
      #     to the new spot, and use that as the input
      letter = key2string(input) #TODO it was better before, use patern matching here to extract `letter` here
      {:fire_actions, [
        # update the buffer text
        {:modify_buffer, %{
            buffer: active_buf,
            details: {:insert, letter, %{coords: {:cursor, 1}}} #TODO why is it always cursor 1?
            # update_buffer?: true #TODO kinda crude but lets do it
        }},
        # move the cursor along 1 character
        {:move_cursor, %{
            buffer: active_buf,
            details: %{cursor_num: 1, instructions: {:right, 1, :column}}
        }}
      ]}
  end


  def key_def(_state, @lowercase_x) do
    {:execute_function, fn -> raise "intentionally raising! you pressed little x!!" end}
  end

end
