defmodule Flamelex.API.KeyMappings.VimClone.KommandMode do
  alias Flamelex.Fluxus.Structs.RadixState
  use Flamelex.GUI.ScenicEventsDefinitions
  require Logger


  def keymap(%RadixState{mode: :kommand}, @escape_key) do
    # {:fire_action, {:switch_mode, :normal}} #TODO this doesn't de-activate the command buffer (unless we get gui broadcast working...)
    {:fire_actions, [
      {KommandBuffer, :hide}, #TOD this should be de-activate, so it clears the buffer
      {:switch_mode, :normal}
    ]}

    # GenServer.cast(Flamelex.Buffer.KommandBuffer, :execute)
    # GenServer.cast(Flamelex.Buffer.KommandBuffer, :clear_and_hide)
  end


  def keymap(%RadixState{mode: :kommand}, @enter_key) do
    {:fire_action, {KommandBuffer, :execute}}
    # GenServer.cast(Flamelex.Buffer.KommandBuffer, :execute)
    # GenServer.cast(Flamelex.Buffer.KommandBuffer, :hide)
  end


  def keymap(%RadixState{mode: :kommand}, input)
  #TODO maybe this should be an action...
    when input in @valid_text_input_characters do
      Logger.debug "detected a valid character as input in :kommand mode: #{inspect input}"
      GenServer.cast(KommandBuffer, {:input, input})
  end




  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @left_shift_and_space_bar) do
  #   Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
  #   state
  # end

  # def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @space_bar = input) do
  #   Scene.action({'COMMAND_BUFFER_INPUT', input})
  #   state |> add_to_input_history(input)
  # end
end
