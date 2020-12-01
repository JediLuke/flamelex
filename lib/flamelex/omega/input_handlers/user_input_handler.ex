defmodule Flamelex.GUI.UserInputHandler do
  @moduledoc false
  require Logger
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState


  # This module acts on inputs, which when combined with an OmegaState,
  # can be fed into specific functions via pattern matching. These
  # functions may have side-effects, which cause the GUI to be updated,
  # or a buffer to change, or anything really.
  def handle_input(%OmegaState{} = omega_state, input) do
    if we_need_to_update_omega_state_atomically_when_processing_this?(input) do
      spawn_new_syncronous_task_handler()
      |> Task.await()
    else
      {:ok, _pid} = spawn_new_async_task_handler(omega_state, input)
      omega_state # return state unaltered
    end
  end


  def key_mapping do
    # get the module which contains the key mappings
    Application.fetch_env!(:flamelex, :key_mapping)
  end


  #TODO how can we know what input requres waiting (because we awant to change some OmegaState atomically), and what doesnt?
  defp we_need_to_update_omega_state_atomically_when_processing_this?(_input) do
    false  #TODO
  end


  defp spawn_new_syncronous_task_handler do
    raise "woops!"
    # Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
    #   # Do something
    # end)
  end

  defp spawn_new_async_task_handler(omega_state, input) do
    Flamelex.Omega.UserInput.TaskSupervisor
    |> Task.Supervisor.start_child(
         key_mapping(),        # module
         :async_handle_input,  # function
         [omega_state, input]) # args
  end
end
