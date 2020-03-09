defmodule GUI.Reducer.ControlMode do
  @moduledoc """
  Contains module attribute definitions of all the Scenic input events.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do

      def process({%{command_buffer: %{visible?: false}, mode: :control} = state, _graph}, 'SHOW_COMMAND_BUFFER') do
        {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
        new_command_buffer_map =
          state.command_buffer
          |> Map.replace!(:visible?, true)

        GenServer.cast(pid, {:action, 'SHOW_COMMAND_BUFFER'})
        %{state|command_buffer: new_command_buffer_map}
      end

      def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'CLEAR_AND_CLOSE_COMMAND_BUFFER') do
        new_command_buffer_map =
          state.command_buffer |> Map.replace!(:visible?, false)

        {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
        GenServer.cast(pid, {:action, 'CLEAR_BUFFER_TEXT'})
        GenServer.cast(pid, {:action, 'HIDE_COMMAND_BUFFER'})

        %{state|command_buffer: new_command_buffer_map}
      end

      def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE' = action) do
        {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
        GenServer.cast(pid, {:action, action})
        state
      end

      def process({%{command_buffer: %{visible?: true}} = state, _graph}, {'COMMAND_BUFFER_INPUT', _input} = action) do
        {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
        GenServer.cast(pid, {:action, action})
        state
      end

      def process({%{command_buffer: %{visible?: true}} = state, _graph}, 'PROCESS_COMMAND_BUFFER_TEXT_AS_COMMAND' = action) do
        {:command_buffer, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
        GenServer.cast(pid, {:action, action})
        state
      end
    end
  end
end
