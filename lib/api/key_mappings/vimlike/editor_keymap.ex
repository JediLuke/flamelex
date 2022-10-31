defmodule Flamelex.Keymaps.Editor do
    use ScenicWidgets.ScenicEventsDefinitions
    require Logger

    alias Flamelex.KeyMappings.Vim

    @valid_inputs @valid_text_input_characters ++ [@escape_key]
    # #NOTE: This Keymap contains the "global", Flamelex-wide keymaps.
    # @leader :key_space

    # # open the KommandBudder with keybinding <leader>k
    # def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_k) do
    #     Logger.debug "Opening KommandBuffer..."
    #     Flamelex.API.Kommander.show()
    #     :ok
    # end

    # # open the Memex with keybinding <leader>h
    # def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_h) do
    #     Flamelex.API.Memex.open()
    #     :ok
    # end

    # def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_h) do
    #     Flamelex.API.Memex.open()
    #     :ok
    # end

    def handle(%{root: %{active_app: :editor}, editor: %{buffers: buffers, active_buf: active_buf}} = radix_state, input) when input in @valid_inputs do
        buf = buffers |> Enum.find(& &1.id == active_buf)
        case buf.mode do
            {:vim, :normal} ->
                Logger.debug "-- mode: #{inspect buf.mode}, input: #{inspect input}"
                Vim.NormalMode.handle(radix_state, input)
            {:vim, :insert} ->
                Vim.InsertMode.handle(radix_state, input)
            other_mode ->
                raise "Buffer does not support mode: #{inspect other_mode}"
        end
    end

end