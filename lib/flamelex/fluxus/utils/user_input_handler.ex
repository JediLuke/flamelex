defmodule Flamelex.Fluxus.UserInputHandler do
  use Flamelex.ProjectAliases
  alias Flamelex.Fluxus.Structs.RadixState


  def handle(radix_state, {:user_input, ii}) do
    # spin up a process under the TaskSupervisor to do the lookup -
    # that process will then fire off any actions it needs to
    #NOTE: no need to await any callback from handling user input

    Task.Supervisor.start_child(
      Flamelex.Fluxus.Input2ActionLookup.TaskSupervisor,
          __MODULE__,                       # module
          :lookup_action_for_input_async,   # function
          [radix_state, ii]                 # args
    )
  end


  #NOTE: this function is defined here, but it is run in it's own process...
  def lookup_action_for_input_async(%RadixState{} = radix_state, user_input) do

    # IO.puts "#{__MODULE__} processing input... #{inspect event}"

    #TODO key_mapping should be? a property of RadixState?
    # key_mapping = Application.fetch_env!(:flamelex, :key_mapping)
    key_mapping = Flamelex.Utils.KeyMappings.VimClone #TODO just hard-code it for now, much easier...

    case key_mapping.lookup(radix_state, user_input) do
      nil ->
          :no_mapping_found
      :ignore_input ->
          :ok
      {:action, a} ->
          Flamelex.Fluxus.fire_action(a)
      {:multiple_actions, action_list} when is_list(action_list) and length(action_list) > 0 ->
          action_list |> Enum.map(&Flamelex.Fluxus.fire_action/1)
      {:apply_mfa, {module, function, args}} ->
          apply_mfa(module, function, args)
      {:execute_function, f} when is_function(f) ->
          f.()
    end
  end

  defp apply_mfa(module, function, args) do
    # try do
      result = Kernel.apply(module, function, args)
      if result == :err_not_handled do
        IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}, #{inspect args}"
      else
        result |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
      end
    # rescue
    #   _e in UndefinedFunctionError ->
    #     IO.puts ""
    #     # Flamelex.Utilities.TerminalIO.red("Ignoring input #{inspect input}...\n\nMod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
    #     # |> IO.puts()
    #   e ->
    #     raise e
    # end
  end
end
