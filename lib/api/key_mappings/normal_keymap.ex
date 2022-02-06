defmodule Flamelex.Keymaps.Normal do
    use ScenicWidgets.ScenicEventsDefinitions
    require Logger

    #NOTE: This Keymap contains the "global", Flamelex-wide keymaps.

    def handle(%{history: %{keystrokes: [:key_space|_rest]}} = radix_state, @lowercase_k) do
        Logger.debug "Opening KommandBuffer..."
        Flamelex.API.Kommander.show()
        {:ok, radix_state}
    end
  
    def handle(%{history: %{keystrokes: [:key_space|_rest]}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        Logger.debug "Handling... #{inspect input}"
        IO.puts "\n\nLAST KEY WAS SPACE\n\n"
        {:ok, radix_state}
    end
  
    # def handle(radix_state, input) do
    #     Logger.debug "#{__MODULE__} ignoring... #{inspect input}"
    #     {:ok, radix_state}
    # end
end