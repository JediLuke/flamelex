defmodule Flamelex.Fluxus.UserInputHandler do
    @moduledoc """
    This is the highest-level input handler. All user-input gets routed
    through this module.
    """
    require Logger
    use ScenicWidgets.ScenicEventsDefinitions
    alias Flamelex.Keymaps

    #NOTE: kommander.hidden? == false, means it is NOT hidden, i.e. KommandBuffer is visible
    def handle(%{kommander: %{hidden?: false}} = radix_state, input) do
        Keymaps.Kommander |> handle_with_rescue(radix_state, input)
    end

    def handle(%{kommander: %{hidden?: true}} = radix_state, input) do
        #TODO use similat try/do & first try global level, then Memex level
        Keymaps.Normal |> handle_with_rescue(radix_state, input)
    end



    defp handle_with_rescue(reducer, radix_state, input) do
        try do
            reducer.handle(radix_state, input)
        rescue
            FunctionClauseError ->
                Logger.warn "input: #{inspect input} not handled."
                # {:ok, radix_state |> record_input(input)}
                :ignore
        else
            :ok ->
                {:ok, radix_state |> record_input(input)}
            {:ok, new_radix_state} ->
                {:ok, new_radix_state |> record_input(input)}
            :ignore ->
                :ignore
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
  