
defmodule Flamelex.GUI.Control.UserInput.Handler do
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
  alias Flamelex.GUI.Control.Input.KeyMapping


  # @readme "/Users/luke/workbench/elixir/franklin/README.md"
  # @dev_tools "/Users/luke/workbench/elixir/franklin/lib/utilities/dev_tools.ex"


  @leader_key @space_bar


  ## -------------------------------------------------------------------
  ## Command mode
  ## -------------------------------------------------------------------


  def handle_input(%OmegaState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
    Flamelex.CommandBufr.deactivate()
    Flamelex.OmegaMaster.switch_mode(:normal)
    state |> OmegaState.set(mode: :normal)
  end

  def handle_input(%OmegaState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
    Flamelex.CommandBufr.input(input)
    state
  end

  def handle_input(%OmegaState{mode: :command} = state, @enter_key) do
    Flamelex.CommandBufr.execute()
    Flamelex.CommandBufr.deactivate()
    state |> OmegaState.set(mode: :normal)
  end


  ## -------------------------------------------------------------------
  ## Normal mode
  ## -------------------------------------------------------------------

  def handle_input(%OmegaState{mode: :normal, active_buffer: nil} = state, input) do
    Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
    state |> OmegaState.add_to_history(input)
  end

  def handle_input(%OmegaState{mode: :normal, active_buffer: active_buf} = state, input) do
    Logger.debug "received some input whilst in :normal mode... #{inspect input}"
    # buf = Buffer.details(active_buf)
    case KeyMapping.lookup_action(state, input) do
      :ignore_input ->
          state
          |> OmegaState.add_to_history(input)
      {:apply_mfa, {module, function, args}} ->
          Kernel.apply(module, function, args)
            |> IO.inspect
          state |> OmegaState.add_to_history(input)
    end
  end

  def handle_input(%OmegaState{mode: :insert} = state, input) when input in @all_letters do
    cursor_pos =
      {:gui_component, state.active_buffer}
      |> ProcessRegistry.find!()
      |> GenServer.call(:get_cursor_position)


    {:codepoint, {letter, _num}} = input

    Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

    state |> OmegaState.add_to_history(input)
  end

  def handle_input(%OmegaState{mode: :insert} = state, input) do
    Logger.debug "received some input whilst in :insert mode"
    state |> OmegaState.add_to_history(input)
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
  # def handle_input(%OmegaState{} = state, input) do
  #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  #   state # ignore
  #   |> IO.inspect(label: "-- DEBUG --")
  # end
end
