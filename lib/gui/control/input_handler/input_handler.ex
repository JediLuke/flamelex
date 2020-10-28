
defmodule Flamelex.InputHandler do
  @moduledoc """
  This module acts on inputs, which when combined with an OmegaState, can
  be fed into specific functions via pattern matching. These functions
  may have side-effects, which cause the GUI to be updated, or a buffer to
  change, or anything really.
  """
  require Logger
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState


  # @readme "/Users/luke/workbench/elixir/franklin/README.md"
  # @dev_tools "/Users/luke/workbench/elixir/franklin/lib/utilities/dev_tools.ex"


  @leader_key @space_bar


  ## -------------------------------------------------------------------
  ## Command mode
  ## -------------------------------------------------------------------


  def handle_input(%OmegaState{mode: :command} = state, @escape_key) do
    IO.puts "11111"
    Flamelex.CommandBufr.deactivate()
    state |> OmegaState.set(mode: :normal)
  end

  def handle_input(%OmegaState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
    IO.puts "22222"
    Flamelex.CommandBufr.input(input)
    state
  end

  def handle_input(%OmegaState{mode: :command} = state, @enter_key) do
    IO.puts "33333"
    Flamelex.CommandBufr.execute()
    Flamelex.CommandBufr.deactivate()
    state |> OmegaState.set(mode: :normal)
  end


  ## -------------------------------------------------------------------
  ## Normal mode
  ## -------------------------------------------------------------------


  def handle_input(%OmegaState{mode: :normal} = state, @leader_key = input) do
    Logger.info "Leader was pressed !!"

    IO.puts "44444"
    state
    |> OmegaState.add_to_history(input)
  end

  ## leader bindings

  def handle_input(%OmegaState{mode: :normal, input: %{history: [@leader_key | _rest]}} = state, input) do
    IO.puts "5555"

    if input == @lowercase_k do
            Logger.info "Activating CommandBufr..."
            Flamelex.CommandBufr.show()
            state
            |> OmegaState.add_to_history(input)
            |> OmegaState.set(mode: :command)
    else
      state |> OmegaState.add_to_history(input)
    end
  end



  # def handle_input(%OmegaState{mode: :normal} = state, @lowercase_h) do
  #   Logger.info "Lowercase h was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   state
  # end

  # def handle_input(%OmegaState{mode: :normal} = state, @lowercase_d) do
  #   Logger.info "Lowercase d was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   state
  # end






  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this can crash (!!)
  # if no action matches what is passed in.
  def handle_input(%OmegaState{} = state, input) do
    IO.puts "7777"
    Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
    state # ignore
    |> IO.inspect(label: "-- DEBUG --")
  end
end
