defmodule Flamelex.Fluxus.Actions.CommandBuffer do
  @moduledoc false
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Fluxus.Structs.RadixState

  def handle(%RadixState{} = state, input) when input in @valid_command_buffer_inputs do
    Flamelex.API.CommandBuffer.input(input)
    state
  end

  def handle(%RadixState{} = state, @enter_key) do
    Flamelex.API.CommandBuffer.execute()
    Flamelex.API.CommandBuffer.deactivate()
    state |> RadixState.set(mode: :normal)
  end



  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this can crash (!!)
  def handle(%RadixState{} = state, _input) do
    state
    # |> IO.inspect(label: "-- DEBUG --")
  end


  # def handle_input(%RadixState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  #   Flamelex.API.CommandBuffer.deactivate()
  #   Flamelex.FluxusRadix.switch_mode(:normal)
  #   state |> RadixState.set(mode: :normal)
  # end



  # # deactivate the command buffer
  # def process(%{input: %{mode: :command}} = state, @escape_key) do
  #   Logger.debug "Closing CommandBuffer..."
  #   Franklin.Buffer.Command.deactivate()

  #   state.input.mode |> put_in(:normal)
  # end

  # def process(%{input: %{mode: :command}} = state, input) when input in @valid_command_buffer_inputs do
  #   {:codepoint, {char, _num}} = input
  #   # Flamelex.Buffer.Command.enter_character(char)
  #   state |> add_to_input_history(input)
  # end


  # def process(%{input: %{mode: :command}} = state, @enter_key) do
  #   # Flamelex.Buffer.Command.execute_contents()
  #   state
  # end




  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @left_shift_and_space_bar) do
  #   Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
  #   state
  # end

  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @space_bar = input) do
  #   Scene.action({'COMMAND_BUFFER_INPUT', input})
  #   state |> add_to_input_history(input)
  # end


end
