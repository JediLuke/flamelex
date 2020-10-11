
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


  @readme "/Users/luke/workbench/elixir/franklin/README.md"
  @dev_tools "/Users/luke/workbench/elixir/franklin/lib/utilities/dev_tools.ex"


  # def identity(%OmegaState{} = omega) do
  #   omega
  # end


  ## -------------------------------------------------------------------
  ## Command mode
  ## -------------------------------------------------------------------


  def handle_input(%OmegaState{mode: :command} = state, @escape_key) do
    Flamelex.Commander.deactivate()
    state |> OmegaState.set(mode: :normal)
  end


  ## -------------------------------------------------------------------
  ## Normal mode
  ## -------------------------------------------------------------------


  def handle_input(%OmegaState{mode: :normal} = state, @space_bar) do
    # we need to do 2 separate things here,
    # 1) Send a msg to CommandBuffer (separate process) to show itself
    # 2) Update the state of the Scene.Root, because this state affects
    #    what future inputs get mapped to
    Logger.info "Space bar was pressed !!"
    Flamelex.Commander.activate()
    state |> OmegaState.set(mode: :command)
  end

  def handle_input(%OmegaState{mode: :normal} = state, @lowercase_h) do
    Logger.info "Lowercase h was pressed !!"
    Flamelex.Buffer.load(type: :text, file: @readme)
    state
  end

  def handle_input(%OmegaState{mode: :normal} = state, @lowercase_d) do
    Logger.info "Lowercase d was pressed !!"
    Flamelex.Buffer.load(type: :text, file: @dev_tools)
    state
  end

  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this can crash (!!)
  # if no action matches what is passed in.
  def handle_input(%OmegaState{} = state, input) do
    # Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
    state # ignore
    # |> IO.inspect(label: "-- DEBUG --")
  end
end
