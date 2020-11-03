defmodule Flamelex.GUI.Control.Input.KeyMapping do
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState

  def lookup_action(%OmegaState{mode: :normal, active_buffer: active_buf} = state, input) do
    normal_action(state.input.history, active_buf, input)
  end


  def normal_action(_history, active_buf, @lowercase_h) do
    {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [active_buf, {:left, 1}]}}
  end

  def normal_action(_history, active_buf, @lowercase_j) do
    {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [active_buf, {:down, 1}]}}
  end

  def normal_action(_history, active_buf, @lowercase_k) do
    {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [active_buf, {:up, 1}]}}
  end

  def normal_action(_history, active_buf, @lowercase_l) do
    {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [active_buf, {:right, 1}]}}
  end

  def normal_action(_history, _active_buf, @lowercase_i) do
    {:apply_mfa, {OmegaMaster, :switch_mode, [:insert]}}
  end

  def normal_action(_history, _buf, _input) do
    :ignore_input
  end


  # def handle_input(%OmegaState{mode: :normal} = state, @lowercase_k) do

  #   IO.puts "moving to the right..."

  #   state
  #   |> OmegaState.add_to_history(@lowercase_k)
  # end

  # def handle_input(%OmegaState{mode: :normal} = state, @leader_key = input) do
  #   Logger.info "Leader was pressed !!"
  #   state
  #   |> OmegaState.add_to_history(input)
  # end

  # def handle_input(%OmegaState{mode: :normal} = state, input) do
  #   Logger.debug "ignoring an input... #{inspect input}"
  #   state
  #   |> OmegaState.add_to_history(input)
  # end



  # ## leader bindings

  # def handle_input(%OmegaState{mode: :normal, input: %{history: [@leader_key | _rest]}} = state, input) do

  #   if input == @lowercase_k do
  #           Logger.info "Activating CommandBufr..."
  #           Flamelex.CommandBufr.show()
  #           state
  #           |> OmegaState.add_to_history(input)
  #           |> OmegaState.set(mode: :command)
  #   else
  #     state |> OmegaState.add_to_history(input)
  #   end
  # end

end
