defmodule Flamelex.Fluxus.RootReducer do

  #NOTE: handle must return an ok/error tuple, & may update the RadixState

  def handle(radix_state, {:action, a}) do
    raise "cant handle actions yet!"
  end
end



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






      # defmodule Flamelex.Fluxus.TransStatum.ActionHandler do
      #   use Flamelex.ProjectAliases
      #   alias Flamelex.Fluxus.Structs.RadixState


      #   def reduce(radix_state, {:active_buffer, :move_cursor, details}) do
      #     #TODO fetch active buffer
      #     #TODO send msg
      #     IO.puts "TODO MOVE CURSOR #{inspect details}"

      #     radix_state
      #   end

      #   def reduce(radix_state, {topic, :switch_mode, new_mode}) do

      #     PubSub.broadcast(
      #       topic: topic, #REMINDER: BufferManager & GUiController are subscribed to `:active_buffer` alerts
      #       msg: {topic, :switch_mode, new_mode})

      #     radix_state |> RadixState.set(mode: new_mode)
      #   end

      #   # def reduce(_radix_state, unmatched_action) do
      #   #   IO.puts "\n\n\nno action matched: #{inspect unmatched_action}\n\n"
      #   #   :no_updates_to_radix_state
      #   # end
      # end





#       defmodule Flamelex.Fluxus.TransStatum do #TODO change to EventHandler
#   use Flamelex.ProjectAliases
#   alias Flamelex.Fluxus.Structs.RadixState
#   alias Flamelex.Fluxus.TransStatum.ActionHandler



#   def handle(radix_state, {:user_input, event}) do
#     spawn_async_handler_process(radix_state, {:user_input, event})
#     :ok #NOTE: no awaiting a callback from handling user input
#   end

#   def handle(radix_state, {:action, a}) do
#     spawn_async_handler_process(radix_state, {:action, a})
#     await_callback()
#   end


#   #NOTE: this function is defined here, but it is run in it's own process
#   def handle_action_async(%RadixState{} = radix_state, action) do
#     case ActionHandler.reduce(radix_state, action) do
#       :no_updates_to_radix_state ->
#           Flamelex.FluxusRadix
#           |> Kernel.send({:ok, :no_updates_to_radix_state})
#       %RadixState{} = new_radix_state ->
#           Flamelex.FluxusRadix
#           |> Kernel.send({:action_callback, {:ok, new_radix_state}})
#     end
#   end

#   #NOTE: this function is defined here, but it is run in it's own process,
#   #      see: `spawn_async_handler_process/3`
#   def lookup_input_async(%RadixState{} = radix_state, event) do
#     IO.puts "#{__MODULE__} processing input... #{inspect event}"

#     #TODO key_mapping should be? a property of RadixState?
#     #NOTE: `key_mapping` is  module, which (eventually) will be a `KeyMapping`
#     #      behaviour - this infrastructure is in place, but until I get more
#     #      than 1 key-mapping even made, I'm just gonna hard-code the
#     #      exact module name for safety
#     # key_mapping = Application.fetch_env!(:flamelex, :key_mapping)
#     key_mapping = Flamelex.Utils.KeyMappings.VimClone

#     case key_mapping.lookup(radix_state, event) do
#       :ignore_input ->
#           IO.puts "mapping found, but we're ignoring input..."
#           :ok
#       nil ->
#           IO.puts "no mapping found..."
#           :ok
#       {:action, a} ->
#           IO.puts "action!! #{inspect a}"
#           Flamelex.FluxusRadix.handle_action(a) # dispatch the action by casting a msg back to FluxusRadix
#           :ok

#       # invalid_response ->
#       #     IO.puts "\n\nthe input: #{inspect event} did not return a valid response: #{inspect invalid_response}"
#       #     :error

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

#     # try do
#       lookup_action(key_mapping, radix_state, event) ##TODO get the active buffer & pass it in??
#     # rescue
#     #   _e in FunctionClauseError ->
#     #     # if we do not pattern-match on any lookup in the key_mapping...
#     #     # IO.puts "could not find a lookup, ignoring event: #{inspect event}..."
#     #     :error
#     # end
#   end


#   # private functions


#   defp lookup_action(key_mapping, radix_state, event) do
#     case key_mapping.lookup(radix_state, event) do
#       :ignore_input ->
#           IO.puts "mapping found, but we're ignoring input..."
#           :ok
#       nil ->
#           IO.puts "no mapping found..."
#           :ok
#       {:action, a} ->
#           IO.puts "action!! #{inspect a}"
#           Flamelex.FluxusRadix.handle_action(a) # dispatch the action by casting a msg back to FluxusRadix
#           :ok
#       # invalid_response ->
#       #     IO.puts "\n\nthe input: #{inspect event} did not return a valid response: #{inspect invalid_response}"
#       #     :error

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

#   defp spawn_async_handler_process(radix_state, {:action, action}) do
#     Task.Supervisor.start_child(
#       Flamelex.Fluxus.HandleAction.TaskSupervisor,
#           __MODULE__,             # module
#           :handle_action_async,   # function
#           [radix_state, action])   # args
#   end

#   defp spawn_async_handler_process(radix_state, {:user_input, event}) do
#     Task.Supervisor.start_child(
#       Flamelex.Fluxus.Input2ActionLookup.TaskSupervisor,
#           __MODULE__,             # module
#           :lookup_input_async,    # function
#           [radix_state, event])    # args
#   end

#   @action_callback_timeout 12
#   defp await_callback do
#     receive do
#       {:action_callback, results} ->
#         #NOTE: don't use a match here - if we get a msg back, let that
#         #      msg tell us if it is an ok/error tuple or not
#         results
#     after
#       @action_callback_timeout ->
#         {:error, "timed out waiting for the action to callback"}
#     end
#   end
# end











  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  # #   Flamelex.API.CommandBuffer.deactivate()
  # #   Flamelex.FluxusRadix.switch_mode(:normal)
  # #   state |> RadixState.set(mode: :normal)
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
  # #   Flamelex.API.CommandBuffer.input(input)
  # #   state
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :command} = state, @enter_key) do
  # #   Flamelex.API.CommandBuffer.execute()
  # #   Flamelex.API.CommandBuffer.deactivate()
  # #   state |> RadixState.set(mode: :normal)
  # # end


  # # ## -------------------------------------------------------------------
  # # ## Normal mode
  # # ## -------------------------------------------------------------------

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: nil} = state, input) do
  # #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
  # #   state |> RadixState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: active_buf} = state, input) do
  # #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  # #   # buf = Buffer.details(active_buf)
  # #   case KeyMapping.lookup_action(state, input) do
  # #     :ignore_input ->
  # #         state
  # #         |> RadixState.add_to_history(input)
  # #     {:apply_mfa, {module, function, args}} ->
  # #         Kernel.apply(module, function, args)
  # #           |> IO.inspect
  # #         state |> RadixState.add_to_history(input)
  # #   end
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, @enter_key = input) do
  # #   cursor_pos =
  # #     {:gui_component, state.active_buffer}
  # #     |> ProcessRegistry.find!()
  # #     |> GenServer.call(:get_cursor_position)

  # #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  # #   state |> RadixState.add_to_history(input)
  # # end

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






  # # This function acts as a catch-all for all actions that don't match
  # # anything. Without this, the process which calls this can crash (!!)
  # # if no action matches what is passed in.
  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{} = state, input) do
  # #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  # #   state # ignore
  # #   |> IO.inspect(label: "-- DEBUG --")
  # # end






















  # defmodule Flamelex.GUI.Control.Input.KeyMapping do
  #   use Flamelex.ProjectAliases
  #   use Flamelex.GUI.ScenicEventsDefinitions
  #   alias Flamelex.Fluxus.Structs.RadixState


  #   @active_keybinding :vim_inspired_flamelex




  #   @doc """
  #   This map defines the effect of pressing a key, to a function call.
  #   """
  #   def binding(:vim_inspired_flamelex, %{mode: :normal, active_buffer: buf}) do
  #     %{
  #       # normal mode navigation
  #       @lowercase_h => move_cursor(buf, {:left,  1}),
  #       @lowercase_j => move_cursor(buf, {:down,  1}),
  #       @lowercase_k => move_cursor(buf, {:up,    1}),
  #       @lowercase_l => move_cursor(buf, {:right, 1}),

  #       # switch modes
  #       @lowercase_i => {:apply_mfa, {FluxusRadix, :switch_mode, [:insert]}},

  #       # leader keys
  #       leader() => %{
  #         @lowercase_k => {:apply_mfa, {Flamelex.API.CommandBuffer, :show, []}}
  #       }
  #     }
  #   end


  #   @doc """
  #   This function is called by FluxusRadix to handle any user input.
  #   """
  #   # def lookup(%RadixState{input: %{history: [last_key | _rest]}} = radix_state, input) do
  #   def lookup(%RadixState{} = radix_state, input) do
  #     # if last_key == leader() do
  #     #   fetch_leader_mapping(radix_state, input)
  #     # else
  #       fetch_mapping(radix_state, input)
  #     # end
  #   end


  #   defp fetch_leader_mapping(radix_state, input) do
  #     if b = binding(@active_keybinding, radix_state)[leader()][input] != nil do
  #       IO.inspect b, label: "BBBB"
  #       binding(@active_keybinding, radix_state)[leader()][input]
  #     else
  #       :ignore_input
  #     end
  #   end


  #   defp fetch_mapping(radix_state, input) do
  #     if binding(@active_keybinding, radix_state)[input] != nil do
  #       binding(@active_keybinding, radix_state)[input]
  #     else
  #       :ignore_input
  #     end
  #   end


  #   # defp move_cursor(active_text_bufr, {direction, x}) do
  #   #   {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [active_text_bufr, {direction,  x}]}}
  #   # end
  # end








  #   # # @readme "/Users/luke/workbench/elixir/franklin/README.md"
  #   # # @dev_tools "/Users/luke/workbench/elixir/franklin/lib/utilities/dev_tools.ex"




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






  #   # This function acts as a catch-all for all actions that don't match
  #   # anything. Without this, the process which calls this can crash (!!)
  #   # if no action matches what is passed in.
  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{} = state, input) do
  #   #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  #   #   state # ignore
  #   #   |> IO.inspect(label: "-- DEBUG --")
  #   # end
