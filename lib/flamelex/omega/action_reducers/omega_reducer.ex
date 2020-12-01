defmodule Flamelex.Omega.Reducer do
  alias Flamelex.Structs.OmegaState

  def process_action(%OmegaState{mode: :normal} = state, {:switch_mode, m}) do
    IO.puts "Omega reducing!! #{inspect m}"
    state
  end

  # def switch_mode(m), do: GenServer.cast(__MODULE__, {:switch_mode, m})
  # def open_buffer(params), do: GenServer.call(__MODULE__, {:open_buffer, params})
  # def show(:command_buffer = x), do: GenServer.cast(__MODULE__, {:show, x})
  # def hide(:command_buffer = x), do: GenServer.cast(__MODULE__, {:hide, x




  # def handle_cast({:switch_mode, m}, omega_state) do

  #   {:gui_component, omega_state.active_buffer}
  #   |> ProcessRegistry.find!
  #   |> GenServer.cast({:switch_mode, m})

  #   # :ok = Flamelex.GUI.Controller.switch_mode(m)

  #   {:noreply, %{omega_state|mode: m}}
  # end



  # #TODO maybe x will be worth considering eventually???
  # def handle_cast({:show, :command_buffer}, omega_state) do
  #   case Buffer.read(:command_buffer) do
  #     data when is_bitstring(data) ->
  #       new_omega_state = %{omega_state|mode: :command}
  #       #TODO so this should then be responsible for managing the buffer process (starting/stopping/finding if sleeping) nd causing it to refresh, whilst also making it visible by forcing a redraw
  #       Flamelex.API.GUI.Component.CommandBuffer.show()
  #       {:noreply, new_omega_state}
  #     e ->
  #       raise "Unable to read Buffer.Command. #{inspect e}"
  #   end
  # end

  # def handle_cast({:hide, :command_buffer}, omega_state) do
  #   # Flamelex.GUI.Controller.hide(:command_buffer)
  #   Flamelex.API.GUI.Component.CommandBuffer.hide()
  #   {:noreply, %{omega_state|mode: :normal}}
  # end

  # def handle_call({:open_buffer, %{
  #   type: :text,
  #   from_file: filepath,
  #   open_in_gui?: true
  # } = params}, _from, omega_state) do

  #   {:ok, new_buf} = BufferManager.open_buffer(params)

  #   :ok = Flamelex.GUI.Controller.show({:buffer, filepath}, omega_state)

  #   {:reply, {:ok, new_buf}, %{omega_state|active_buffer: new_buf}}
  # end

  # def handle_call({:open_buffer, %{name: name, open_in_gui?: true} = params}, _from, omega_state) do

  #   {:ok, new_buf} = BufferManager.open_buffer(params)

  #   :ok = Flamelex.GUI.Controller.show({:buffer, name}, omega_state)

  #   {:reply, {:ok, new_buf}, %{omega_state|active_buffer: new_buf}}
  # end
end
