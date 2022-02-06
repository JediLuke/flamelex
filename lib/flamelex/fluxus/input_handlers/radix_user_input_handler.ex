defmodule Flamelex.Fluxus.RadixUserInputHandler do
    @moduledoc """

    """
    require Logger
    use ScenicWidgets.ScenicEventsDefinitions
    alias Flamelex.Keymaps

    #NOTE: kommander.hidden? == false, means it is NOT hidden, i.e. KommandBuffer is visible
    def handle(%{kommander: %{hidden?: false}} = radix_state, input) do
        {:ok, new_radix_state} = Keymaps.Kommander.handle(radix_state, input)
        {:ok, new_radix_state |> record_input(input)}
    end

    def handle(%{kommander: %{hidden?: true}} = radix_state, input) do
        try do
            {:ok, new_radix_state} = Keymaps.Normal.handle(radix_state, input)
            {:ok, new_radix_state |> record_input(input)}
        rescue
            FunctionClauseError ->
                Logger.warn "input: #{inspect input} not handled."
                {:ok, radix_state |> record_input(input)}
        end
    end


  
    defp record_input(radix_state, {:key, {key, @key_pressed, []}} = input) when input in @valid_text_input_characters do
        Logger.debug "-- Recording INPUT: #{inspect input}"
        #NOTE: We store the latest keystroke at the front of the list, not the back
        radix_state
        |> put_in([:history, :keystrokes], radix_state.history.keystrokes |> List.insert_at(0, key))
    end

    defp record_input(radix_state, input) do
        Logger.debug "NOT recording: #{inspect input} as input..."
        radix_state
    end
  end
  