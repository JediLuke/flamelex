# defmodule Flamelex.Omega.UserInputHandler do
#   @moduledoc false
#   require Logger
#   use Flamelex.ProjectAliases
#   use Flamelex.GUI.ScenicEventsDefinitions
#   alias Flamelex.Structs.OmegaState


#   # This module acts on inputs, which when combined with an OmegaState,
#   # can be fed into specific functions via pattern matching. These
#   # functions may have side-effects, which cause the GUI to be updated,
#   # or a buffer to change, or anything really.
#   def handle_input(%OmegaState{} = omega_state, input) do
#     # if we_need_to_update_omega_state_atomically_when_processing_this?(input) do
#     #   spawn_new_syncronous_task_handler()
#     #   |> Task.await()
#     # else
#       {:ok, _pid} = spawn_new_async_task_handler(omega_state, input)
#       omega_state # return state unaltered
#     # end
#   end


#   def key_mapping do
#     # get the module which contains the key mappings
#     Application.fetch_env!(:flamelex, :key_mapping)
#   end


#   def spawn_new_syncronous_task_handler do
#     raise "woops!"
#     # Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
#     #   # Do something
#     # end)
#   end


#   def spawn_new_async_task_handler(omega_state, input) do
#     Flamelex.Omega.Input2ActionLookup.TaskSupervisor
#     |> Task.Supervisor.start_child(
#          __MODULE__,                            # module
#          :lookup_action,                        # function
#          [key_mapping(), omega_state, input])   # args
#   end

#   #NOTE: key_mapping is an Elixir module implementing the KeyMapping behaviour #TODO
#   def lookup_action(key_mapping, %OmegaState{} = omega_state, input) do
#     Logger.debug "processing input... #{inspect input}"
#     case key_mapping.lookup(omega_state, input) do
#       :ignore_input ->
#           :ok
#       {:action, a} ->
#           #TODO dispatch the action




#       # {:apply_mfa, {module, function, args}} ->
#       #     try do
#       #       if res = Kernel.apply(module, function, args) == :err_not_handled do
#       #         IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}"
#       #       else
#       #         res
#       #         |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
#       #       end
#       #     rescue
#       #       _e in UndefinedFunctionError ->
#       #         Flamelex.Utilities.TerminalIO.red("Ignoring input #{inspect input}...\n\nMod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
#       #         |> IO.puts()
#       #       e ->
#       #         raise e
#       #     end
#     end
#   end

#   #TODO how can we know what input requres waiting (because we awant to change some OmegaState atomically), and what doesnt?
#   defp we_need_to_update_omega_state_atomically_when_processing_this?(_input) do
#     false  #TODO
#   end
# end
