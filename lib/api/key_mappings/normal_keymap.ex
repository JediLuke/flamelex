defmodule Flamelex.Keymaps.Normal do
    use ScenicWidgets.ScenicEventsDefinitions
    require Logger

    #NOTE: This Keymap contains the "global", Flamelex-wide keymaps.

    def handle(%{history: %{keystrokes: [:key_space|_rest]}} = radix_state, @lowercase_k) do
        Logger.debug "Opening KommandBuffer..."
        Flamelex.API.Kommander.show()
        {:ok, radix_state}
    end

    def handle(%{history: %{keystrokes: [:key_space|_rest]}} = radix_state, @lowercase_h) do
        Flamelex.API.Memex.open()
        {:ok, radix_state}
    end

    #TODO in editor mode, save the buffer with leader-s

    def handle(%{history: %{keystrokes: [:key_space|_rest]}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        Logger.debug "Handling... #{inspect input}"
        IO.puts "\n\nLAST KEY WAS SPACE\n\n"
        {:ok, radix_state}
    end
  
    def handle(_radix_state, input) when input in @valid_text_input_characters do
        #REMINDER: We need to acknowledge the keystrokes in order to save
        # them into the keystroke history
        :ok
    end
end