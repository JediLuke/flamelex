defmodule Flamelex.Utils.KeyMappings.VimClone do
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState


  #TODO should be a behaviour...


  @doc """
  This function is called by OmegaMaster to handle any user input.
  """
  def lookup(%OmegaState{mode: m} = omega_state, input) when m in [:normal, :command] do
    if input == leader_key() do
      :ignore_input
    else
      lookup_keystroke(omega_state, leader_key(), input)
    end
  end


  @doc """
  This function defines which key acts as the `leader`.
  """
  def leader_key, do: @space_bar


  def lookup_keystroke(%OmegaState{mode: m} = omega_state, leader, input) when m in [:normal, :command] do
    lookup_result =
      if omega_state |> OmegaState.last_keystroke() == leader_key() do
        keymap(omega_state)[leader][input]
      else
        keymap(omega_state)[input]
      end

    if lookup_result == nil do
      :ignore_input
    else
      lookup_result
    end
  end



  @doc """
  This map defines the effect of pressing a key, to a function call.
  """
  def keymap(%OmegaState{}) do
    %{
      # normal mode navigation
      @lowercase_h => move_cursor(:left, 1),
      @lowercase_j => move_cursor(:down, 1),
      @lowercase_k => move_cursor(:up, 1),
      @lowercase_l => move_cursor(:right, 1),

      # switch modes
      @lowercase_i => {:apply_mfa, {Flamelex, :switch_mode, [:insert]}},

      # leader keys
      leader_key() => %{
        @lowercase_j => {:apply_mfa, {Flamelex.API.Journal, :today, []}},
        @lowercase_k => {:apply_mfa, {Flamelex.API.CommandBuffer, :show, []}}
      }
    }
  end


  defp move_cursor(direction, amount) do
    {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [:active_buffer, {direction,  amount}]}}
  end
end




  # # def handle_input(%Flamelex.Structs.OmegaState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  # #   Flamelex.API.CommandBuffer.deactivate()
  # #   Flamelex.OmegaMaster.switch_mode(:normal)
  # #   state |> OmegaState.set(mode: :normal)
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
  # #   Flamelex.API.CommandBuffer.input(input)
  # #   state
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, @enter_key) do
  # #   Flamelex.API.CommandBuffer.execute()
  # #   Flamelex.API.CommandBuffer.deactivate()
  # #   state |> OmegaState.set(mode: :normal)
  # # end


  # # ## -------------------------------------------------------------------
  # # ## Normal mode
  # # ## -------------------------------------------------------------------

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal, active_buffer: nil} = state, input) do
  # #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
  # #   state |> OmegaState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal, active_buffer: active_buf} = state, input) do
  # #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  # #   # buf = Buffer.details(active_buf)
  # #   case KeyMapping.lookup_action(state, input) do
  # #     :ignore_input ->
  # #         state
  # #         |> OmegaState.add_to_history(input)
  # #     {:apply_mfa, {module, function, args}} ->
  # #         Kernel.apply(module, function, args)
  # #           |> IO.inspect
  # #         state |> OmegaState.add_to_history(input)
  # #   end
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, @enter_key = input) do
  # #   cursor_pos =
  # #     {:gui_component, state.active_buffer}
  # #     |> ProcessRegistry.find!()
  # #     |> GenServer.call(:get_cursor_position)

  # #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  # #   state |> OmegaState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) when input in @all_letters do
  # #   cursor_pos =
  # #     {:gui_component, state.active_buffer}
  # #     |> ProcessRegistry.find!()
  # #     |> GenServer.call(:get_cursor_position)


  # #   {:codepoint, {letter, _num}} = input

  # #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  # #   state |> OmegaState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) do
  # #   Logger.debug "received some input whilst in :insert mode"
  # #   state |> OmegaState.add_to_history(input)
  # # end




  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_h) do
  # #   Logger.info "Lowercase h was pressed !!"
  # #   Flamelex.Buffer.load(type: :text, file: @readme)
  # #   state
  # # end

  # # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_d) do
  # #   Logger.info "Lowercase d was pressed !!"
  # #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  # #   state
  # # end






  # # This function acts as a catch-all for all actions that don't match
  # # anything. Without this, the process which calls this can crash (!!)
  # # if no action matches what is passed in.
  # # def handle_input(%Flamelex.Structs.OmegaState{} = state, input) do
  # #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  # #   state # ignore
  # #   |> IO.inspect(label: "-- DEBUG --")
  # # end






















  # defmodule Flamelex.GUI.Control.Input.KeyMapping do
  #   use Flamelex.ProjectAliases
  #   use Flamelex.GUI.ScenicEventsDefinitions
  #   alias Flamelex.Structs.OmegaState


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
  #       @lowercase_i => {:apply_mfa, {OmegaMaster, :switch_mode, [:insert]}},

  #       # leader keys
  #       leader() => %{
  #         @lowercase_k => {:apply_mfa, {Flamelex.API.CommandBuffer, :show, []}}
  #       }
  #     }
  #   end


  #   @doc """
  #   This function is called by OmegaMaster to handle any user input.
  #   """
  #   # def lookup(%OmegaState{input: %{history: [last_key | _rest]}} = omega_state, input) do
  #   def lookup(%OmegaState{} = omega_state, input) do
  #     # if last_key == leader() do
  #     #   fetch_leader_mapping(omega_state, input)
  #     # else
  #       fetch_mapping(omega_state, input)
  #     # end
  #   end


  #   defp fetch_leader_mapping(omega_state, input) do
  #     if b = binding(@active_keybinding, omega_state)[leader()][input] != nil do
  #       IO.inspect b, label: "BBBB"
  #       binding(@active_keybinding, omega_state)[leader()][input]
  #     else
  #       :ignore_input
  #     end
  #   end


  #   defp fetch_mapping(omega_state, input) do
  #     if binding(@active_keybinding, omega_state)[input] != nil do
  #       binding(@active_keybinding, omega_state)[input]
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


  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: mode} = state, @escape_key) when mode in [:command, :insert] do
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   Flamelex.OmegaMaster.switch_mode(:normal)
  #   #   state |> OmegaState.set(mode: :normal)
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, input) when input in @valid_command_buffer_inputs do
  #   #   Flamelex.API.CommandBuffer.input(input)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :command} = state, @enter_key) do
  #   #   Flamelex.API.CommandBuffer.execute()
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   state |> OmegaState.set(mode: :normal)
  #   # end


  #   # ## -------------------------------------------------------------------
  #   # ## Normal mode
  #   # ## -------------------------------------------------------------------

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal, active_buffer: nil} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
  #   #   state |> OmegaState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal, active_buffer: active_buf} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  #   #   # buf = Buffer.details(active_buf)
  #   #   case KeyMapping.lookup_action(state, input) do
  #   #     :ignore_input ->
  #   #         state
  #   #         |> OmegaState.add_to_history(input)
  #   #     {:apply_mfa, {module, function, args}} ->
  #   #         Kernel.apply(module, function, args)
  #   #           |> IO.inspect
  #   #         state |> OmegaState.add_to_history(input)
  #   #   end
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, @enter_key = input) do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)

  #   #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  #   #   state |> OmegaState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) when input in @all_letters do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)


  #   #   {:codepoint, {letter, _num}} = input

  #   #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  #   #   state |> OmegaState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :insert} = state, input) do
  #   #   Logger.debug "received some input whilst in :insert mode"
  #   #   state |> OmegaState.add_to_history(input)
  #   # end




  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_h) do
  #   #   Logger.info "Lowercase h was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Structs.OmegaState{mode: :normal} = state, @lowercase_d) do
  #   #   Logger.info "Lowercase d was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   #   state
  #   # end






  #   # This function acts as a catch-all for all actions that don't match
  #   # anything. Without this, the process which calls this can crash (!!)
  #   # if no action matches what is passed in.
  #   # def handle_input(%Flamelex.Structs.OmegaState{} = state, input) do
  #   #   Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
  #   #   state # ignore
  #   #   |> IO.inspect(label: "-- DEBUG --")
  #   # end
