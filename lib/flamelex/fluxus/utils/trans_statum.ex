defmodule Flamelex.Fluxus.TransStatum do #TODO change to EventHandler
  use Flamelex.ProjectAliases
  alias Flamelex.Fluxus.Structs.RadixState
  alias Flamelex.Fluxus.TransStatum.ActionHandler



  def handle(radix_state, {:user_input, event}) do
    spawn_async_handler_process(radix_state, {:user_input, event})
    :ok #NOTE: no awaiting a callback from handling user input
  end

  def handle(radix_state, {:action, a}) do
    spawn_async_handler_process(radix_state, {:action, a})
    await_callback()
  end


  #NOTE: this function is defined here, but it is run in it's own process
  def handle_action_async(%RadixState{} = radix_state, action) do
    case ActionHandler.reduce(radix_state, action) do
      :no_updates_to_radix_state ->
          Flamelex.FluxusRadix
          |> Kernel.send({:ok, :no_updates_to_radix_state})
      %RadixState{} = new_radix_state ->
          Flamelex.FluxusRadix
          |> Kernel.send({:action_callback, {:ok, new_radix_state}})
    end
  end

  #NOTE: this function is defined here, but it is run in it's own process
  def lookup_input_async(%RadixState{} = radix_state, event) do
    IO.puts "#{__MODULE__} processing input... #{inspect event}"

    #TODO key_mapping should be? a property of RadixState?
    #NOTE: `key_mapping` is  module, which (eventually) will be a `KeyMapping`
    #      behaviour - this infrastructure is in place, but until I get more
    #      than 1 key-mapping even made, I'm just gonna hard-code the
    #      exact module name for safety
    key_mapping = Flamelex.Utils.KeyMappings.VimClone
    # key_mapping = Application.fetch_env!(:flamelex, :key_mapping)

    ##TODO get the active buffer & pass it in??

    case key_mapping.lookup(radix_state, event) do
      :ignore_input ->
          IO.puts "ignoring input..."
          :ok
      {:action, a} ->
          IO.puts "action!! #{inspect a}"
          Flamelex.FluxusRadix.handle_action(a) # dispatch the action by casting a msg back to FluxusRadix
      invalid_response ->
          IO.puts "\n\nthe input: #{inspect event} did not return a valid response: #{inspect invalid_response}"
          :error

      # {:apply_mfa, {module, function, args}} ->
      #     try do
      #       if res = Kernel.apply(module, function, args) == :err_not_handled do
      #         IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}"
      #       else
      #         res
      #         |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
      #       end
      #     rescue
      #       _e in UndefinedFunctionError ->
      #         Flamelex.Utilities.TerminalIO.red("Ignoring input #{inspect input}...\n\nMod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
      #         |> IO.puts()
      #       e ->
      #         raise e
      #     end
    end
  end


  # private functions


  defp spawn_async_handler_process(radix_state, {:action, action}) do
    Task.Supervisor.start_child(
      Flamelex.Fluxus.HandleAction.TaskSupervisor,
          __MODULE__,             # module
          :handle_action_async,   # function
          [radix_state, action])   # args
  end

  defp spawn_async_handler_process(radix_state, {:user_input, event}) do
    Task.Supervisor.start_child(
      Flamelex.Fluxus.Input2ActionLookup.TaskSupervisor,
          __MODULE__,             # module
          :lookup_input_async,    # function
          [radix_state, event])    # args
  end

  @action_callback_timeout 12
  defp await_callback do
    receive do
      {:action_callback, results} ->
        #NOTE: don't use a match here - if we get a msg back, let that
        #      msg tell us if it is an ok/error tuple or not
        results
    after
      @action_callback_timeout ->
        {:error, "timed out waiting for the action to callback"}
    end
  end
end
