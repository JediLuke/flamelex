defmodule Flamelex.Fluxus.Radix.UserInputHandler do
  @moduledoc """
  This is the highest-level input handler. All user-input gets routed
  through this module.

  This is the level we use to figure out which lower-level input handler/s
  should be used to process the input. If we can direct input to a lower-level
  here using whatever apps are open, then theoretically we dont need to keep
  writing long expressive, yes safe but also cumbersome guards in
  our lower-level input handlers.
  """
  require Logger
  alias Flamelex.GUI.Component.{QlxWrap, TODOlist}
  use Flamelex.Keymaps.Editor.GlobalBindings

  # TODO one day might need a more sophisticated way of handling this... maybe send to both components?
  # maybe match on cases where one vs both is actually up?
  def handle(
        %{layers: %{one: %{active_apps: [TODOlist | _rest]}}} = rdx,
        input
      ) do
    TODOlist.UserInputHandler.handle(rdx, input)
  end

  def handle(
        %{
          layers: %{one: %{active_apps: [QlxWrap]}},
          apps: %{qlx_wrap: %{active_buf: %{mode: {:vim, :insert}}}}
         } = rdx,
        input
      ) do
    QlxWrap.UserInputHandler.handle(rdx, input)
  end

  #TODO consider having just one history queue for both keystrokes and actions, then
  # we solve the potential problem of where I press space in insert mode, use CLI to switch to normal mode
  # then press some button and it treats it like I just pressed leader+k or whatever
  # alternatively, have multiple history queues and as we switch modes we save input into different queues - this
  # might work better when we consider that e.g. Kommander might want a different history aswell, for same reasons

  def handle(
    %{
      layers: %{
        four: %{kommander_active?: true}
      }
    } = rdx,
    input
  ) do
    Flamelex.Keymaps.Kommander.handle(rdx, input)
  end


  # toggle kommander when no apps are open
  def handle(
        %{
          layers: %{
            one: %{active_apps: []},
            four: %{kommander_active?: false}
          },
          history: %{keystrokes: [@leader|_rest]}
        } = rdx,
        @lowercase_k
      ) do
    [:open_kommander]
    # send each action to the RadixReducer wrapped in a routing-tuple, it helps make the reducers easier to write
    |> Enum.map(& {Flamelex.GUI.Component.Kommander, &1})
  end

  def handle(
        %{
          layers: %{
            one: %{active_apps: [QlxWrap]},
            four: %{kommander_active?: false}
          },
          apps: %{qlx_wrap: %{active_buf: %{mode: {:vim, :normal}}}},
          history: %{keystrokes: [@leader|_rest]}
        } = rdx,
        @lowercase_k
      ) do
    [:open_kommander]
    # send each action to the RadixReducer wrapped in a routing-tuple, it helps make the reducers easier to write
    |> Enum.map(& {Flamelex.GUI.Component.Kommander, &1})
  end

  def handle(
        %{
          layers: %{one: %{active_apps: [QlxWrap]}},
          apps: %{qlx_wrap: %{active_buf: %{mode: {:vim, :normal}}}},
          history: %{keystrokes: [@sub_leader|_rest]}
        } = rdx,
        @lowercase_s
      ) do
    # QlxWrap.UserInputHandler.handle(rdx, input)
    IO.puts "LAST KEY WS SPACE!!! here we should split the buffer!"
    :ignore
  end

  def handle(
        %{
          layers: %{one: %{active_apps: [QlxWrap]}},
          apps: %{qlx_wrap: %{active_buf: %{mode: {:vim, :normal}}}}
        } = rdx,
        input
      ) do
    Logger.debug "routing through RDX-QlxWrap..."
    QlxWrap.UserInputHandler.handle(rdx, input)
  end

  # Handle input when no apps are active - allow visual feedback to work
  def handle(
        %{
          layers: %{one: %{active_apps: []}}
        } = rdx,
        input
      ) do
    Logger.info "🎯 MCP Test: Processing input with no active apps - #{inspect input}"
    # Return :ignore to let the visual feedback in RootScene work
    # The RootScene will handle the visual feedback before forwarding to Fluxus
    :ignore
  end

  def handle(rdx, input) do
    Logger.warning "#{__MODULE__} Ignoring input #{inspect input}..."
    :ignore
  end
end




# defmodule Flamelex.Keymaps.Desktop do
#   use Flamelex.Keymaps.Editor.GlobalBindings
#   require Logger

#   @ignorable_keys [@shift_space, @meta, @left_ctrl, @left_alt]

#   def process(_radix_state, @leader) do
#     # Logger.debug " <<-- Leader key pressed -->>"
#     :ok
#   end

#   def process(%{kommander: %{hidden?: false}}, @escape_key) do
#     :ok = Flamelex.API.Kommander.hide()
#   end

#   def process(_radix_state, @escape_key) do
#     :ignore
#   end

#   def process(_radix_state, @lowercase_k) do
#     :ok = Flamelex.API.Kommander.show()
#   end

#   def process(_radix_state, key) when key in @ignorable_keys do
#     :ignore
#   end

#   def process(_radix_state, {:cursor_button, _details}) do
#     # NOTE - don't handle mouse events at this level, let lower components e.g. MenuBar handle mouse events
#     :ignore
#   end

#   ## Leader-x keybindings
#   ## --------------------

#   # open the Kommander with keybinding <leader>k
#   def process(%{history: %{keystrokes: [@leader | _rest]}} = radix_state, @lowercase_k) do
#     # Logger.debug "Opening KommandBuffer..."
#     :ok = Flamelex.API.Kommander.show()
#   end

#   def process(
#         %{
#           root: %{layers: %{one: %{explorer: %{active?: true}}}},
#           history: %{keystrokes: [@sub_leader | _rest]}
#         } = radix_state,
#         @lowercase_e
#       ) do
#     Flamelex.API.Editor.hide_explorer()
#   end

#   def process(%{history: %{keystrokes: [@sub_leader | _rest]}} = radix_state, @lowercase_e) do
#     Flamelex.API.Editor.show_explorer()
#   end

#   # NOTE - this has to go below the match where we record the history of pressing @leader
#   def process(_radix_state, key) when key in @valid_text_input_characters do
#     :ignore
#   end

#   def process(_radix_state, @left_shift) do
#     :ignore
#   end

#   def process(radix_state, key) do
#     raise "Unhandled key: #{inspect(key)}"
#   end

#   # open the Memex with keybinding <leader>h
#   # def process(@lowercase_h, %{history: %{keystrokes: [@leader|_rest]}} = radix_state) do
#   #    :ok = Flamelex.API.Diary.open()
#   # end
# end




  # def handle(_rdx, {:key, {:key_leftalt, _up_or_down, _weird_list}}) do
  #   Logger.debug("Ignoring key_leftalt...")
  #   :ignore
  # end

  # if we only have one app open then we can just pass the input to that app
  # def handle(
  #       %{layers: %{one: %{active_apps: [app]}}} = rdx,
  #       input
  #     ) do
  #   # raise "we shouldnt be doing this lol"
  #   IO.puts("WARNING - App: #{inspect(app)} did not have a specific handler in #{__MODULE__}...")
  #   Module.concat(app, UserInputHandler).handle(rdx, input)
  # end


# def process(
#       %{
#         layers: %{
#           one: %{
#             active_apps: [
#               {Flamelex.GUI.Component.RapidSelector, _state}
#             ]
#           }
#         }
#       } = rdx,
#       input
#     ) do
#   Flamelex.Fluxus.RapidSelectorUserInputHandler.process(rdx, input)
# end

# #   # TODO look for this module/file & see if it exists before attempting this
# #   case Memelex.My.Modz.CustomInputHandler.process(radix_state, input) do
# #     :ignore ->
# #       Logger.debug("Memelex.My.Modz.CustomInputHandler ignoring... #{inspect(%{input: input})}")
# #       EventBus.mark_as_completed({__MODULE__, event_shadow})

# #     {:ok, ^radix_state} ->
# #       # Logger.debug "#{Memelex.My.Modz.CustomInputHandler} ignoring (no state-change)..."
# #       EventBus.mark_as_completed({__MODULE__, event_shadow})

# #     {:ok, new_radix_state} ->
# #       # Logger.debug "#{Memelex.My.Modz.CustomInputHandler} processed event, state changed..."
# #       # NOTE - we only need to `put` user input into the store, dont call `update` because we dont need to broadcast this out to all components...
# #       Flamelex.Fluxus.RadixStore.put(new_radix_state)
# #       EventBus.mark_as_completed({__MODULE__, event_shadow})
# #   end
# # end

# # NOTE: kommander.hidden? == false, means it is NOT hidden, i.e. KommandBuffer is visible
# def process(%{kommander: %{hidden?: false}} = radix_state, input) do
#   Flamelex.Keymaps.Kommander |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :desktop}} = radix_state, input) do
#   Flamelex.Keymaps.Desktop |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :editor}} = radix_state, input) do
#   # TODO route this to QuillEx
#   # QuillEx.Fluxus.input(input)
#   Flamelex.Keymaps.Editor |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :memex}} = radix_state, input) do
#   # fire it off to Memelex, they can worry about this one...
#   # Memelex.Fluxus.input(input)
#   Logger.warn("NEED TO HANDLE MEMEX INPUT")
#   :ignore
# end

#   # IN THE FUTURE - we route all input to the GUI.Controller
#   # - this is the process which is able to understand the state of the GUI
#   # (as it holds the "frame", "active_buffer" and other such things in it)
#   # -

#   # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
#   # #   cursor_pos =
#   # #     {:gui_component, state.active_buffer}
#   # #     |> ProcessRegistry.find!()
#   # #     |> GenServer.call(:get_cursor_position)

#   # #   {:codepoint, {letter, _num}} = input

#   # #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

#   # #   state |> RadixState.add_to_history(input)
#   # # end

#   # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
#   # #   Logger.debug "received some input whilst in :insert mode"
#   # #   state |> RadixState.add_to_history(input)
#   # # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: mode} = state, @escape_key) when mode in [:kommand, :insert] do
#   #   #   Flamelex.API.CommandBuffer.deactivate()
#   #   #   Flamelex.FluxusRadix.switch_mode(:normal)
#   #   #   state |> RadixState.set(mode: :normal)
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :kommand} = state, input) when input in @valid_command_buffer_inputs do
#   #   #   Flamelex.API.CommandBuffer.input(input)
#   #   #   state
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :kommand} = state, @enter_key) do
#   #   #   Flamelex.API.CommandBuffer.execute()
#   #   #   Flamelex.API.CommandBuffer.deactivate()
#   #   #   state |> RadixState.set(mode: :normal)
#   #   # end

#   #   # ## -------------------------------------------------------------------
#   #   # ## Normal mode
#   #   # ## -------------------------------------------------------------------

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: nil} = state, input) do
#   #   #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
#   #   #   state |> RadixState.add_to_history(input)
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: active_buf} = state, input) do
#   #   #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
#   #   #   # buf = Buffer.details(active_buf)
#   #   #   case KeyMapping.lookup_action(state, input) do
#   #   #     :ignore_input ->
#   #   #         state
#   #   #         |> RadixState.add_to_history(input)
#   #   #     {:apply_mfa, {module, function, args}} ->
#   #   #         Kernel.apply(module, function, args)
#   #   #         state |> RadixState.add_to_history(input)
#   #   #   end
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, @enter_key = input) do
#   #   #   cursor_pos =
#   #   #     {:gui_component, state.active_buffer}
#   #   #     |> ProcessRegistry.find!()
#   #   #     |> GenServer.call(:get_cursor_position)

#   #   #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

#   #   #   state |> RadixState.add_to_history(input)
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
#   #   #   cursor_pos =
#   #   #     {:gui_component, state.active_buffer}
#   #   #     |> ProcessRegistry.find!()
#   #   #     |> GenServer.call(:get_cursor_position)

#   #   #   {:codepoint, {letter, _num}} = input

#   #   #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

#   #   #   state |> RadixState.add_to_history(input)
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
#   #   #   Logger.debug "received some input whilst in :insert mode"
#   #   #   state |> RadixState.add_to_history(input)
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_h) do
#   #   #   Logger.info "Lowercase h was pressed !!"
#   #   #   Flamelex.Buffer.load(type: :text, file: @readme)
#   #   #   state
#   #   # end

#   #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_d) do
#   #   #   Logger.info "Lowercase d was pressed !!"
#   #   #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
#   #   #   state
#   #   # end

#   def handle(radix_state, {:user_input, ii}) do
#     #Logger.debug "#{__MODULE__} handling some user input: #{inspect ii}"

#     # spin up a process under the TaskSupervisor to do the lookup -
#     # that process will then fire off any actions it needs to

#     #NOTE: no need to await any callback from handling user input

#     Task.Supervisor.start_child(
#       Flamelex.Fluxus.InputHandler.TaskSupervisor,
#           __MODULE__,                       # module
#           :lookup_action_for_input_async,   # function
#           [radix_state, ii]                 # args
#     )
#   end

#   #NOTE: this function is defined here, but it is run in it's own process...
#   def lookup_action_for_input_async(%{mode: m} = radix_state, user_input)
#     when m in [:normal, :insert, :kommand] do
#     Logger.debug "Async Process: lookup_action_for_input_async - #{inspect user_input}"

#     #TODO just hard-code it for now, much easier...
#     Flamelex.KeyMappings.Vim.lookup(radix_state, user_input.input) #TODO here user_input still has all this shit in it (user_input.input <vomit>)
#     |> handle_lookup(radix_state)

#     # # IO.puts "#{__MODULE__} processing input... #{inspect event}"

#     # #TODO key_mapping should be? a property of RadixState?
#     # # key_mapping = Application.fetch_env!(:flamelex, :key_mapping)
#     # key_mapping = Flamelex.KeyMappings.Vim #TODO just hard-code it for now, much easier...

#     # #TODO this should probably be a lookup inside the module?
#     # #     or rather, maybe we pass the module into the lookup function?
#     #
#     # case key_mapping.lookup(radix_state, user_input.input) do #TODO this is not grat, probably need to ditch the rest first
#     #   nil ->
#     #       _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
#     #       # Logger.warning "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
#     #       :no_mapping_found
#     #   :ok ->
#     #       :ok
#     #   :ignore_input ->
#     #       :ok
#     #   {:fire_action, a} ->
#     #       Logger.debug " -- FIRING ACTION --> #{inspect a}"
#     #       Flamelex.Fluxus.fire_action(a)

#     #   #TODO deprecate it, just have 1 pattern match for vim_lang here
#     #   {:vim_lang, x, v} ->
#     #       GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
#     #   {:vim_lang, v} ->
#     #       GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
#     #   {:apply_mfa, {module, function, args}} ->
#     #       apply_mfa(module, function, args)
#     #   {:execute_function, f} when is_function(f) ->
#     #       f.()
#     # end
#   end

#   def handle_lookup(nil, _radix_state) do
#     # _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
#     # Logger.warning "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
#     :no_mapping_found
#   end

#   def handle_lookup(:ok, _radix_state), do: :ok

#   def handle_lookup({:vim_lang, v}, radix_state) do
#     GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
#   end

#   def handle_lookup({:vim_lang, x, v}, radix_state) do
#     GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
#   end

#   def handle_lookup(:ok, _radix_state), do: :ok

#   def handle_lookup({:execute_function, f}, _radix_state) when is_function(f) do
#     f.()
#   end

#   def handle_lookup({:apply_mfa, {module, function, args}}, _radix_state) do
#     apply_mfa(module, function, args)
#   end

#   def handle_lookup(:ignore_input, _radix_state), do: :ok

# #   case key_mapping.lookup(radix_state, user_input.input) do #TODO this is not grat, probably need to ditch the rest first
# #   nil ->
# #       _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
# #       # Logger.warning "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
# #       :no_mapping_found
# #   :ok ->
# #       :ok
# #   :ignore_input ->
# #       :ok
# #   {:fire_action, a} ->
# #       Logger.debug " -- FIRING ACTION --> #{inspect a}"
# #       Flamelex.Fluxus.fire_action(a)
# #   {:fire_actions, action_list} when is_list(action_list) and length(action_list) > 0 ->
# #       action_list |> Enum.map(fn (m) ->
# #         Flamelex.Fluxus.fire_action(m)
# #     end)
# #   #TODO deprecate it, just have 1 pattern match for vim_lang here
# #   {:vim_lang, x, v} ->
# #       GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
# #   {:vim_lang, v} ->
# #       GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
# #   {:apply_mfa, {module, function, args}} ->
# #       apply_mfa(module, function, args)
# #   {:execute_function, f} when is_function(f) ->
# #       f.()
# # end

#   #NOTE: Keep this wrapper, incase we ever want to re-visit the Exception
#   #      catching stuff.
#   defp apply_mfa(module, function, args) do
#     Kernel.apply(module, function, args)
#     # try do
#     #   result = Kernel.apply(module, function, args)
#     #   if result == :err_not_handled do
#     #     IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}, #{inspect args}"
#     #   else
#     #     result |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
#     #   end
#     # rescue
#     #   _e in UndefinedFunctionError ->
#     #     Flamelex.Utilities.TerminalIO.red("Mod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
#     #     |> IO.puts()
#     #   e ->
#     #     raise e
#     # end
#   end

# end

# defp process_with_rescue(reducer, radix_state, input) do
#   try do
#     reducer.process(radix_state, input)
#   rescue
#     FunctionClauseError ->
#       Logger.warn("input: #{inspect(input)} not handled by Reducer `#{inspect(reducer)}`")
#       # TODO should we still record this input??
#       # {:ok, radix_state |> record_input(input)}
#       :ignore
#   else
#     :ok ->
#       {:ok, radix_state |> record_input(input)}

#     # TODO I don't think we should allow any InputHandler to return a RadixState, since we dont broadcast out from them...
#     # {:ok, new_radix_state} ->
#     #    {:ok, new_radix_state |> record_input(input)}
#     :ignore ->
#       :ignore

#     :error ->
#       :error
#   end
# end
