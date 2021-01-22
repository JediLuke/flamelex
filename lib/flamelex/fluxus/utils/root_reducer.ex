defmodule Flamelex.Fluxus.RootReducer do
  alias Flamelex.Fluxus.Structs.RadixState

  @action_timeout 30

  def handle(radix_state, {:action, a}) do
    Task.Supervisor.start_child(
      Flamelex.Fluxus.HandleAction.TaskSupervisor,
      __MODULE__,                       # module
      :execute_action_async,            # function
      [radix_state, a]                  # args
    )

    #NOTE: handle must return an ok/error tuple, & may update the RadixState

    receive do
      {:ok, %RadixState{} = new_radix_state} ->
        {:ok, new_radix_state}
    after
      @action_timeout ->
        {:error, "timed out waiting for a callback from the action handling process"}
    end
  end

  def execute_action_async(%RadixState{} = radix_state, {:show, :command_buffer}) do

    Flamelex.GUI.Component.CommandBuffer.show()

    new_radix_state =
        radix_state
        |> RadixState.set(mode: {:command_buffer_active, :insert})

    Flamelex.FluxusRadix
    |> send({:ok, new_radix_state})
  end

  def execute_action_async(%RadixState{} = radix_state, {:active_buffer, :move_cursor, %{to: :last_line}}) do
    #TODO find active buffer
    #TODO then move the cursor to the last line



    Flamelex.FluxusRadix |> send({:ok, radix_state})
  end

  def execute_action_async(%RadixState{} = radix_state, unmatched_action) do
    IO.puts "received an action, that we just can't handle... #{inspect unmatched_action}"
    Flamelex.FluxusRadix |> send({:ok, radix_state})
  end
end





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

































  # defmodule Flamelex.GUI.Root.Reducer do
#   @moduledoc """
#   This module contains functions which process events received from the GUI.

#   #TODO this could be a pretty nice use case for a behaviour, but I like having the automatic pattern-match we get from importing modules #TODO num2 - actually, when it comes to applying layers, pushing actions through layers of reducers (with most important last, so they apply their actions over the top of other ones) might be a good model to use...
#   In Franklin, a Reducer must always return one of three values

#     :ignore                           -> causes Flamelex.GUI.RootScene to ignore action
#     {new_state, new_graph}            -> causes Flamelex.GUI.RootScene to update both it's internal state, & push a new graph
#     new_state when is_map(new_state)  -> causes Flamelex.GUI.RootScene to update it's internal state, but no change to the %Scenic.Graph{} is necessary

#   """
#   require Logger
#   use Flamelex.{ProjectAliases, CustomGuards}



#   # def process(
#   #       %{
#   #         layout:
#   #           %Flamelex.GUI.Structs.Layout{
#   #             arrangement: :floating_frames,
#   #             # dimensions: %Flamelex.GUI.Structs.Dimensions{width: width, height: height},
#   #             frames: []
#   #           }
#   #       } = state,
#   #       {:show_in_gui, buf} = _action) do

#   #   # #TODO we want to use frames etc. but this is more or less it!
#   #   # %{arrangement: _arrangement,
#   #   #    dimensions: %{width: width, height: height}}
#   #   #      = state.layout

#   #   new_frame = Frame.new(
#   #     id:              1, #NOTE: This is ok, because this pattern match is for when we have no frames
#   #     top_left_corner: {25, 25},
#   #     dimensions:      {800, 1200},
#   #     buffer:          buf)

#   #       # picture_graph:   GUI.Component.TextBox.new(buf)
#   #       # picture_graph:   Draw.blank_graph()
#   #       #                  |> Draw.text("Yes yes", {100, 100}) #TODO although inelegant, this is drawing text inside the frame!!

#   #   #TODO need to make sure our ordering is correct so frames are layered on top of eachother
#   #   new_graph =
#   #     state.graph
#   #     # |> GUI.Component.Frame.add_to_graph(new_frame)

#   #   new_layout =
#   #     %{state.layout|frames: state.layout.frames ++ [new_frame]}

#   #   new_state =
#   #     %{state|graph: new_graph, layout: new_layout}

#   #   {:redraw_root_scene, new_state}
#   # end


#   # def process(
#   #   %{
#   #     layout:
#   #       %Flamelex.GUI.Structs.Layout{
#   #         arrangement: :floating_frames,
#   #         # dimensions: %Flamelex.GUI.Structs.Dimensions{width: width, height: height},
#   #         frames: [%Frame{} = f] # one frame
#   #       }
#   #   } = state,
#   #   {:show_in_gui, buf} = _action) do


#   #     new_frame = Frame.new(
#   #       id:              2,
#   #       top_left_corner: {850, 25},
#   #       dimensions:      {800, 1200},
#   #       buffer:          buf)


#   #     #TODO need to make sure our ordering is correct so frames are layered on top of eachother
#   #     new_graph =
#   #       state.graph
#   #       # |> GUI.Component.Frame.add_to_graph(new_frame)

#   #     new_layout =
#   #       %{state.layout|frames: state.layout.frames ++ [new_frame]}

#   #     new_state =
#   #       %{state|graph: new_graph, layout: new_layout}

#   #     {:redraw_root_scene, new_state}
#   # end

#   # def process(
#   # %{layout: %Flamelex.GUI.Structs.Layout{
#   #       arrangement: :floating_frames,
#   #       frames: frame_list}
#   # } = state,
#   # {:show_in_gui, buf} = _action)
#   # when length(frame_list) > 2 do
#   #   IO.puts ""

#   # end

#   #TODO this is a protocol
#   #
#   # defprotocol Utility do
#   #   @spec type(t) :: String.t()
#   #   def type(value)
#   # end

#   # defimpl Utility, for: BitString do
#   #   def type(_value), do: "string"
#   # end

#   # defimpl Utility, for: Integer do
#   #   def type(_value), do: "integer"
#   # end





#   def process(state, {:show, buf}) do

#     new_frame = Frame.new(
#       id:              9,
#       top_left_corner: {100, 100},
#       dimensions:      {200, 200},
#       buffer:          buf)


#     new_graph =
#       state.graph
#       # |> GUI.Component.Frame.add_to_graph(new_frame)

#     new_state =
#       %{state|graph: new_graph}

#     {:redraw_root_scene, new_state}
#   end


#   def process(a, b) do
#     IO.inspect b, label: "ACTION"
#     raise "NO #{inspect a} #{inspect b}"
#   end




#   # def process({_scene, graph}, {:show_in_gui, %Buf{} = buf}) do
#   #   new_graph =
#   #     graph
#   #     |> GUI.Utilities.Draw.text(buf.content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

#   #   {:update_graph, new_graph}
#   # end


#   #TODO this at the moment renders a new Text frame
#   # def process({state, graph}, {'NEW_FRAME', [type: :text, content: content]}) do
#   #   new_graph =
#   #     graph
#   #     |> GUI.Utilities.Draw.text(content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

#   #   # update_state_and_graph(state, new_graph) #TODO do we update the state??
#   #   {:update_all, {state, new_graph}}
#   # end


#   # defp update_state_and_graph(new_state, new_graph), do: {:update_all, {new_state, new_graph}}
# end


# ## TODO - below be dragons!















# #   #   {state, graph}
# #   # end

# #   def process({%{viewport: %{width: w}} = state, graph}, {'NEW_NOTE_COMMAND', contents, buffer_pid: buf_pid}) do
# #     width  = w / 3
# #     height = width
# #     top_left_corner_x = (w/2)-(width/2) # center the box
# #     top_left_corner_y = height / 5
# #     id = {:note, generate_note_buffer_id(state.component_ref), buf_pid}

# #     {:note, note_num, _buf_pid} = id
# #     multi_note_offset = (note_num - 1) * 15

# #     new_graph =
# #       graph
# #       |> GUI.Component.Note.add_to_graph(%{
# #            id: id,
# #            top_left_corner: {top_left_corner_x + multi_note_offset, top_left_corner_y + multi_note_offset},
# #            dimensions: {width, height},
# #            contents: contents
# #          }, id: id)

# #     new_state =
# #       state
# #       |> Map.replace!(:active_buffer, id)
# #       |> Map.replace!(:mode, :edit)

# #     {new_state, new_graph}
# #   end

# #   def process({%{viewport: %{width: w, height: h}} = state, graph}, {'NEW_LIST_BUFFER', data}) do

# #     # state = DataFile.read()
# #     command_buffer = state.buffers |> hd()
# #     # id = {:list, :notes, buf_pid}
# #     id = {:list, :notes}

# #     new_graph =
# #       graph
# #       |> GUI.Component.List.add_to_graph(%{
# #           id: id,
# #           top_left_corner: {0, 0},
# #           # dimensions: {w, h - command_buffer.data.height - 1}, #TODO this does put 1 pixel between the two, do we want that??
# #           dimensions: {w, h - command_buffer.data.height},
# #           contents: data
# #         }, id: id)

# #     new_state =
# #       state
# #       |> Map.replace!(:active_buffer, id)
# #       # |> Map.replace!(:mode, :edit)

# #     {new_state, new_graph}

# #     # ibm_plex_mono = Flamelex.GUI.Initialize.ibm_plex_mono_hash()

# #     # add_notes =
# #     #   fn(graph, notes) ->
# #     #     {graph, _offset_count} =
# #     #       Enum.reduce(notes, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
# #     #         graph =
# #     #           graph
# #     #           |> Scenic.Primitives.group(fn graph ->
# #     #                graph
# #     #                |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
# #     #                |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
# #     #                    translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
# #     #                    font_size: 24, fill: :black)
# #     #              end)


# #     #         {graph, offset_count + 1}
# #     #       end)
# #     #     graph
# #     #   end

# #     # new_graph =
# #     #   graph |> add_notes.(notes)

# #   end

# #   def process({state, _graph}, {'NOTE_INPUT', {:note, _x, _pid} = active_buffer, input}) do
# #     [{{:note, _x, buffer_pid}, component_pid}] =
# #       state.component_ref
# #       |> Enum.filter(fn
# #            {^active_buffer, _pid} ->
# #             true
# #          _else ->
# #             false
# #          end)

# #     Franklin.Buffer.Note.input(buffer_pid, {component_pid, input})
# #     state
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'}) do
# #     find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     |> GUI.Component.Note.move_cursor_to_text_section
# #     state
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, graph}, {:active_buffer, :note, 'CLOSE_NOTE_BUFFER'}) do

# #     # find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     # |> GUI.Component.Note.close_buffer

# #     new_graph =
# #       graph |> Scenic.Graph.delete(active_buffer_id)

# #     #TODO here we can de-link the component

# #     {state, new_graph}
# #   end

# #   def process({%{active_buffer: {:note, _x, _pid} = active_buffer_id} = state, _graph}, {:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'}) do
# #     find_component_reference_pid!(state.component_ref, active_buffer_id)
# #     |> GUI.Component.Note.move_cursor_to_title_section
# #     state
# #   end

# #   defp generate_note_buffer_id(component_ref) when is_list(component_ref) do
# #     component_ref
# #     |> Enum.filter(fn
# #          {{:note, _x, _buf_pid}, _pid} ->
# #              true
# #          _else ->
# #              false
# #        end)
# #     |> Enum.count
# #     |> (&(&1 + 1)).()
# #   end
# # end
