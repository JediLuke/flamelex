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

    def handle(%{root: %{active_app: :memex}} = radix_state, input) do
        Flamelex.API.Memex.open()
        :ok
    end

    #TODO in editor mode, save the buffer with leader-s

    # def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, input) do
    #     #   {:error, "UserInputHandler bottomed-out! No match was found."}
    #     Logger.debug "Handling... #{inspect input}"
    #     IO.puts "\n\nLAST KEY WAS SPACE\n\n"
    #     {:ok, radix_state}
    # end
  
    def handle(radix_state, input) when input in @valid_text_input_characters do
        IO.puts "YASSSSS"
        IO.inspect radix_state
        #REMINDER: We need to acknowledge the keystrokes in order to save
        # them into the keystroke history
        :ok
    end
end