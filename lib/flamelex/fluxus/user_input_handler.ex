defmodule Flamelex.Fluxus.UserInputHandler do
  use Flamelex.ProjectAliases
  alias Flamelex.Fluxus.Structs.RadixState
  require Logger




  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
  # #   cursor_pos =
  # #     {:gui_component, state.active_buffer}
  # #     |> ProcessRegistry.find!()
  # #     |> GenServer.call(:get_cursor_position)


  # #   {:codepoint, {letter, _num}} = input

  # #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  # #   state |> RadixState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
  # #   Logger.debug "received some input whilst in :insert mode"
  # #   state |> RadixState.add_to_history(input)
  # # end




  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_h) do
  # #   Logger.info "Lowercase h was pressed !!"
  # #   Flamelex.Buffer.load(type: :text, file: @readme)
  # #   state
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_d) do
  # #   Logger.info "Lowercase d was pressed !!"
  # #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  # #   state
  # # end





  #   # ## -------------------------------------------------------------------
  #   # ## Command mode
  #   # ## -------------------------------------------------------------------


  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   Flamelex.FluxusRadix.switch_mode(:normal)
  #   #   state |> RadixState.set(mode: :normal)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
  #   #   Flamelex.API.CommandBuffer.input(input)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :command} = state, @enter_key) do
  #   #   Flamelex.API.CommandBuffer.execute()
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   state |> RadixState.set(mode: :normal)
  #   # end


  #   # ## -------------------------------------------------------------------
  #   # ## Normal mode
  #   # ## -------------------------------------------------------------------

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: nil} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: active_buf} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  #   #   # buf = Buffer.details(active_buf)
  #   #   case KeyMapping.lookup_action(state, input) do
  #   #     :ignore_input ->
  #   #         state
  #   #         |> RadixState.add_to_history(input)
  #   #     {:apply_mfa, {module, function, args}} ->
  #   #         Kernel.apply(module, function, args)
  #   #           |> IO.inspect
  #   #         state |> RadixState.add_to_history(input)
  #   #   end
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, @enter_key = input) do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)

  #   #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)


  #   #   {:codepoint, {letter, _num}} = input

  #   #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
  #   #   Logger.debug "received some input whilst in :insert mode"
  #   #   state |> RadixState.add_to_history(input)
  #   # end




  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_h) do
  #   #   Logger.info "Lowercase h was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_d) do
  #   #   Logger.info "Lowercase d was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   #   state
  #   # end












  def handle(radix_state, {:user_input, ii}) do

    # spin up a process under the TaskSupervisor to do the lookup -
    # that process will then fire off any actions it needs to

    #NOTE: no need to await any callback from handling user input

    Task.Supervisor.start_child(
      Flamelex.Fluxus.InputHandler.TaskSupervisor,
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
    key_mapping = Flamelex.API.KeyMappings.VimClone #TODO just hard-code it for now, much easier...

    #TODO this should probably be a lookup inside the module?
    #     or rather, maybe we pass the module into the lookup function?
    case key_mapping.lookup(radix_state, user_input) do
      nil ->
          details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
          Logger.warn "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
          :no_mapping_found
      :ignore_input ->
          :ok
      {:fire_action, a} ->
          Flamelex.Fluxus.fire_action(a)
      {:fire_multiple_actions, action_list} when is_list(action_list) and length(action_list) > 0 ->
          action_list |> Enum.map(&Flamelex.Fluxus.fire_action/1)
      #TODO deprecate it, just have 1 pattern match for vim_lang here
      {:vim_lang, x, v} ->
          GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
      {:vim_lang, v} ->
          GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
      {:apply_mfa, {module, function, args}} ->
          # apply_mfa(module, function, args)
          Kernel.apply(module, function, args)
      {:execute_function, f} when is_function(f) ->
          f.()
    end
  end

  defp apply_mfa(module, function, args) do
    try do
      result = Kernel.apply(module, function, args)
      if result == :err_not_handled do
        IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}, #{inspect args}"
      else
        result |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
      end
    rescue
      _e in UndefinedFunctionError ->
        Flamelex.Utilities.TerminalIO.red("Mod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
        |> IO.puts()
      e ->
        raise e
    end
  end
end
