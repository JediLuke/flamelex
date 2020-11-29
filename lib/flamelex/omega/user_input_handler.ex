
defmodule Flamelex.GUI.UserInputHandler do
  @moduledoc """
  This module acts on inputs, which when combined with an OmegaState, can
  be fed into specific functions via pattern matching. These functions
  may have side-effects, which cause the GUI to be updated, or a buffer to
  change, or anything really.
  """
  require Logger
  use Flamelex.ProjectAliases
  use Flamelex.API.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState
  alias Flamelex.API.GUI.Control.Input.KeyMapping


  # @readme "/Users/luke/workbench/elixir/franklin/README.md"
  # @dev_tools "/Users/luke/workbench/elixir/franklin/lib/utilities/dev_tools.ex"


  ## -------------------------------------------------------------------
  ## Command mode
  ## -------------------------------------------------------------------


  def handle_input(%Flamelex.Structs.OmegaState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
    Flamelex.API.CommandBuffer.deactivate()
    Flamelex.OmegaMaster.switch_mode(:normal)
    state |> OmegaState.set(mode: :normal)
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
    Flamelex.API.CommandBuffer.input(input)
    state
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, @enter_key) do
    Flamelex.API.CommandBuffer.execute()
    Flamelex.API.CommandBuffer.deactivate()
    state |> OmegaState.set(mode: :normal)
  end


  ## -------------------------------------------------------------------
  ## Normal mode
  ## -------------------------------------------------------------------

  def handle_input(%Flamelex.Structs.OmegaState{mode: :normal, active_buffer: nil} = state, input) do
    Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
    state |> OmegaState.add_to_history(input)
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, input) do
    Logger.debug "received some input whilst in :normal mode... #{inspect input}"
    case KeyMapping.lookup(state, input) do
      :ignore_input ->
          state |> OmegaState.add_to_history(input)
      {:apply_mfa, {module, function, args}} ->
          Kernel.apply(module, function, args)
            |> IO.inspect
          state |> OmegaState.add_to_history(input)
    end
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, @enter_key = input) do
    cursor_pos =
      {:gui_component, state.active_buffer}
      |> ProcessRegistry.find!()
      |> GenServer.call(:get_cursor_position)

    Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

    state |> OmegaState.add_to_history(input)
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) when input in @all_letters do
    cursor_pos =
      {:gui_component, state.active_buffer}
      |> ProcessRegistry.find!()
      |> GenServer.call(:get_cursor_position)


    {:codepoint, {letter, _num}} = input

    Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

    state |> OmegaState.add_to_history(input)
  end

  def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) do
    Logger.debug "received some input whilst in :insert mode"
    state |> OmegaState.add_to_history(input)
  end




  # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_h) do
  #   Logger.info "Lowercase h was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   state
  # end

  # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_d) do
  #   Logger.info "Lowercase d was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   state
  # end






  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this can crash (!!)
  # if no action matches what is passed in.
  # def handle_input(%Flamelex.Structs.OmegaState{} = state, input) do
  #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  #   state # ignore
  #   |> IO.inspect(label: "-- DEBUG --")
  # end
end

















defmodule Flamelex.API.GUI.Input.EventHandler do
  @moduledoc """
  This module contains functions which process events received from the GUI.
  """
  require Logger
  use Flamelex.API.GUI.ScenicEventsDefinitions


  # eliminate the don't cares
  def process(state, {input, _details}) when input in @inputs_we_dont_care_about do
    state # do nothing - pass through unaltered state
  end


  #TODO do all these in their own process process


  ## Command buffer commands
  ## -------------------------------------------------------------------


  # activate the command buffer
  # def process(%{input: %{mode: :normal}} = state, @space_bar) do
  #   Logger.info "Space bar was pressed  !!"
  #   Franklin.Buffer.Command.activate()
  #   state.input.mode |> put_in(:command)
  # end

  # deactivate the command buffer
  def process(%{input: %{mode: :command}} = state, @escape_key) do
    Logger.debug "Closing CommandBuffer..."
    Franklin.Buffer.Command.deactivate()

    state.input.mode |> put_in(:normal)
  end

  def process(%{input: %{mode: :command}} = state, input) when input in @valid_command_buffer_inputs do
    {:codepoint, {char, _num}} = input
    # Flamelex.Buffer.Command.enter_character(char)
    state |> add_to_input_history(input)
  end

  def process(%{input: %{mode: :command}} = state, @backspace_key) do
    # Flamelex.Buffer.Command.backspace()
    state
  end

  def process(%{input: %{mode: :command}} = state, @enter_key) do
    # Flamelex.Buffer.Command.execute_contents()
    state
  end

  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @left_shift_and_space_bar) do
  #   Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
  #   state
  # end

  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @space_bar = input) do
  #   Scene.action({'COMMAND_BUFFER_INPUT', input})
  #   state |> add_to_input_history(input)
  # end


  ## Active buffer
  ## -------------------------------------------------------------------


  # def process(%{active_buffer: {:note, _x, _pid} = buf} = state, input) when input in @valid_command_buffer_inputs do
  #   Scene.action({'NOTE_INPUT', buf, input})
  #   state |> add_to_input_history(input)
  # end

  # def process(%{active_buffer: {:note, _x, buffer_pid}} = state, @tab_key) do
  #   Franklin.Buffer.Note.tab_key_pressed(buffer_pid)
  #   state
  # end

  # def process(%{active_buffer: {:note, _x, _buffer_pid}, mode: :control} = state, @escape_key) do
  #   Logger.warn "Pressing ESC in control mode does nothing right now."
  #   state
  # end

  # def process(%{active_buffer: {:note, _x, buffer_pid}, mode: :control} = state, @enter_key) do
  #   Franklin.Buffer.Note.save_and_close(buffer_pid)
  #   state
  # end

  # def process(%{active_buffer: {:note, _x, _buffer_pid}, mode: mode} = state, @escape_key) when mode != :control do
  #   #TODO write own action for switching modes
  #   state |> Map.replace!(:mode, :control)
  # end

  # def process(%{active_buffer: {:note, _x, buffer_pid}} = state, @left_shift_and_tab) do
  #   Franklin.Buffer.Note.reverse_tab(buffer_pid) #TODO have better lookup than just pid, so we could use this from cmd line
  #   state
  # end



  # def process(%{command_buffer: %{visible?: false}} = state, @lowercase_j) do
  #   if state.input_history |> List.last == @space_bar do
  #     Scene.action('SHOW_COMMAND_BUFFER')
  #   end
  #   state |> add_to_input_history(@lowercase_j)
  # end



  def process(state, unhandled_event) do
    Logger.debug("#{__MODULE__} Unhandled event: #{inspect(unhandled_event)}")
    state
    |> IO.inspect(label: "-- DEBUG: state --")
  end


  ## private functions
  ## -------------------------------------------------------------------


  #TODO lose input after certain amount
  defp add_to_input_history(state, {:codepoint, _details} = input) do
    state.input.history
    |> put_in(state.input.history ++ [input])
  end
end
