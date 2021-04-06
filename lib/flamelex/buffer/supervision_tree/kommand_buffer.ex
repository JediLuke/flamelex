defmodule Flamelex.Buffer.KommandBuffer do
  @moduledoc """
  This process is responsible for managing the state of the Kommand buffer.

  The KommandBuffer is special - other buffers hold & manipulate data,
  and so does the command buffer, but this data can be actioned upon to
  activate functions, achieve GUI changes etc.

  The GUI component for the KommandBuffer is drawn as part of the Default
  scene. GUIController creates the Default GUI immediately after boot &
  re-draws - so that's how the KommandBuffer GUI component gets drawn.
  """
  use Flamelex.BufferBehaviour
  alias Flamelex.Buffer.Utils.KommandBuffer.ExecuteCommandHelper
  alias Flamelex.Buffer.Utils.TextBuffer.ModifyHelper
  alias Flamelex.Utils.TextManipulationTools, as: TextTools
  require Logger

  @impl Flamelex.BufferBehaviour
  def boot_sequence(params) do

    #NOTE: this process also gets named according to the {:buffer, details}
    #      system as defined in BufferBehaviour... but this is much more
    #      convenient, being able to hard-code sending msgs to KommandBuffer
    Process.register(self(), KommandBuffer)

    {:ok, Map.merge(params, %{data: ""})}
  end


  def handle_cast({:input, {:codepoint, {letter, _num?}}}, state) do
    new_state = %{state|data: state.data <> letter}
    update_gui(new_state |> Map.merge(%{move_cursor: {1, :column, :right}}))
    {:noreply, new_state}
  end

  # def handle_cast({:backspace, x}, state) do
  #   new_data = state.data - x
  #   new_state = %{state|data: new_data}
  #   update_gui(new_state |> Map.merge(%{move_cursor: {1, :column, :left}}))
  #   {:noreply, new_state}
  # end

  def handle_cast({:modify, %{backspace: {:cursor, 1}}}, state) do
    # ModifyHelper.start_modification_task(state, details)
    IO.puts "KommandBuffer is modifying! "
    # {:ok, new_state} = ModifyHelper.modify(state, details)
    new_state = %{state|data: state.data |> TextTools.delete(:last_character)}
    update_gui(new_state |> Map.merge(%{move_cursor: {1, :column, :left}}))
    {:noreply, new_state}
  end


  # @impl GenServer
  def handle_cast(:clear, state) do
    new_state = %{state|data: ""}
    update_gui(new_state)
    {:noreply, new_state} # reset the content to blank
  end


  def handle_cast(:execute, state) do
    # Task.Supervisor.start_child(KommandBuffer.Reducer, :execute_command) #TODO do this under the KommandBuffer.Reducer
    ExecuteCommandHelper.execute_command(state.data)
    # {:noreply, %{state|data: ""}}
    {:noreply, state}
  end


  #TODO this is difficult to test... we need to test, that we sent a correctly updated state?
  def update_gui(state) do
    ProcessRegistry.find!({:gui_component, KommandBuffer})
    |> GenServer.cast({:update, state})
  end
end
