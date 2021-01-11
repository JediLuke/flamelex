defmodule Flamelex.GUI.InputHandler.NormalMode do
  @moduledoc false
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Fluxus.Structs.RadixState


  def handle(%RadixState{} = state, key_mapping, input) do
    case key_mapping.lookup(state, input) do

      :ignore_input ->
          state |> RadixState.add_to_history(input)

      {:apply_mfa, {module, function, args}} ->
          Kernel.apply(module, function, args)
          |> IO.inspect

          state |> RadixState.add_to_history(input)
    end
  end




  # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: active_buf} = state, input) do
  #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  #   # buf = Buffer.details(active_buf)
  #   case KeyMapping.lookup_action(state, input) do
  #     :ignore_input ->
  #         state
  #         |> RadixState.add_to_history(input)
  #     {:apply_mfa, {module, function, args}} ->
  #         Kernel.apply(module, function, args)
  #           |> IO.inspect
  #         state |> RadixState.add_to_history(input)
  #   end
  # end


  # activate the command buffer
  # def process(%{input: %{mode: :normal}} = state, @space_bar) do
  #   Logger.info "Space bar was pressed  !!"
  #   Franklin.Buffer.Command.activate()
  #   state.input.mode |> put_in(:command)
  # end



  # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_h) do
  #   Logger.info "Lowercase h was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   state
  # end

  # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_d) do
  #   Logger.info "Lowercase d was pressed !!"
  #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   state
  # end

end
