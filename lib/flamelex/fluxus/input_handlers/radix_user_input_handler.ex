defmodule Flamelex.Fluxus.RadixUserInputHandler do
    @moduledoc """

    """
    require Logger
    use ScenicWidgets.ScenicEventsDefinitions

    def handle(%{kommander: %{hidden?: false}} = radix_state, @escape_key = input) do
        Flamelex.API.Kommander.hide()
        {:ok, radix_state |> record_input(input)}
    end
  
    def handle(%{kommander: %{hidden?: false}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        IO.puts "KOMMAND KOMMAND"
        :ignore
    end

    def handle(%{kommander: %{hidden?: true}, history: %{keystrokes: [:key_space|_rest]}} = radix_state, @lowercase_k = input) do
        Logger.debug "Opening KommandBuffer..."
        Flamelex.API.Kommander.show()
        {:ok, radix_state |> record_input(input)}
    end
  
    def handle(%{kommander: %{hidden?: true}, history: %{keystrokes: [:key_space|_rest]}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        Logger.debug "Handling... #{inspect input}"
        IO.puts "\n\nLAST KEY WAS SPACE\n\n"
        {:ok, radix_state |> record_input(input)}
    end
  
    def handle(%{kommander: %{hidden?: true}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        Logger.debug "Handling... #{inspect input}"
        :ignore
        {:ok, radix_state |> record_input(input)}
    end
  
    def record_input(radix_state, {:key, {key, @key_pressed, []}} = input) when input in @valid_text_input_characters do
        Logger.debug "-- Recording INPUT: #{inspect input}"
        #NOTE: We store the latest keystroke at the front of the list, not the back
        radix_state
        |> put_in([:history, :keystrokes], radix_state.history.keystrokes |> List.insert_at(0, key))
    end

    def record_input(radix_state, input) do
        Logger.debug "ignoring input... #{inspect input}"
        radix_state
    end
  end
  