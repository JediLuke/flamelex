defmodule Flamelex.Omega.Reducer do
  alias Flamelex.Structs.OmegaState
  use Flamelex.ProjectAliases

  # do pattern-match check on params
  def process_action(%OmegaState{} = omega_state, action, opts) when is_list(opts) do
    do_process_action(omega_state, action, opts)
  end


  def do_process_action(omega_state, {:show, :command_buffer}, _opts) do
    #NOTE: both the buffer, and the GUI.Component, should be registered to this topic!!
    Flamelex.GUI.Component.CommandBuffer.show()
    # PubSub.publish(:command_buffer, :show)
    omega_state |> OmegaState.set(mode: :command)
  end

  def do_process_action(omega_state, {:switch_mode, new_mode}, _opts) do

    #TODO broadcast the new mode to all processes?
    ProcessRegistry.find!(:active_buffer)
    |> GenServer.cast({:action, {:switch_mode, new_mode}})

    # Flamelex.GUI.Controller.switch_mode(new_mode)

    omega_state |> OmegaState.set(mode: new_mode)
  end

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
