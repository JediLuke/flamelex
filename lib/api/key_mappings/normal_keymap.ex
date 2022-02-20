defmodule Flamelex.Keymaps.Normal do
    use ScenicWidgets.ScenicEventsDefinitions
    require Logger

    #NOTE: This Keymap contains the "global", Flamelex-wide keymaps.
    @leader :key_space

    # open the KommandBudder with keybinding <leader>k
    def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_k) do
        Logger.debug "Opening KommandBuffer..."
        Flamelex.API.Kommander.show()
        :ok
    end

    # open the Memex with keybinding <leader>h
    def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_h) do
        Flamelex.API.Memex.open()
        :ok
    end

    def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, @lowercase_h) do
        Flamelex.API.Memex.open()
        :ok
    end


end