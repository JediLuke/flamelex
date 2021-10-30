defmodule Flamelex.BufferManager do
  @moduledoc """
  Coordinates & administrates all the open buffers.
  """
  use GenServer
  use Flamelex.ProjectAliases
  # alias Flamelex.Buffer.Utils.OpenBuffer, as: BufferOpenUtils
  require Logger

  #TODO if a buffer crashes, need to catch it & alert Flamelex.GUI.Controller
  #TODO idea: the GUI should turn grey, with an x through it - but it has memory (text etc) in it - maybe it can be used to recover the Buffer state...

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl GenServer
  def init(_params) do
    Logger.debug "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)

    init_state = %{
      buffer_list: [],        # holds a reference to each open buffer
      active_buffer: nil,     # holds a reference to the `active` buffer
    }

    {:ok, init_state, {:continue, :pubsub_registration}}
  end

  @impl GenServer
  def handle_continue(:pubsub_registration, bufr_mgr_state) do
    Flamelex.Utils.PubSub.subscribe(topic: :action_event_bus) # be notified of `actions` fired internally
    {:noreply, bufr_mgr_state}
  end



  def handle_call({:find_buffer, search_term}, _from, state) do

    #TODO move to a pure function, under a Task.Supervisor
    similarity_cutoff = 0.72 # used to compare how similar the strings are

    find_buf =
      state
      |> Enum.find(
           :no_matching_buffer_found, # this is the default value we return if no element is found by the function below
           fn b ->
             # TheFuzz.compare(:jaro_winkler, search_term, b.label) >= similarity_cutoff
             String.jaro_distance(search_term, b.label) >= similarity_cutoff
           end)

    case find_buf do
      :no_matching_buffer_found ->
        {:reply, {:error, "no matching buffer found"}, state}
      buf ->
        {:reply, {:ok, buf}, state}
    end
  end

  def handle_call(:save_active_buffer, _from, state) do
    results = state.active_buffer
              |> ProcessRegistry.find!()
              |> GenServer.call(:save)

    {:reply, results, state}
  end


  def handle_call(:count_buffers, _from, state) do
    count = Enum.count(state)
    {:reply, count, state}
  end

  # give the BufferManager state to anyone who asks
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast({:buffer_opened, %{rego_tag: {:buffer, KommandBuffer}}}, state) do
    # KommandBuffer - just ignore it...
    {:noreply, state}
  end

  def handle_cast({:buffer_opened, buf_state}, state) do
    #TODO we can do better than this (though, this is still better I think, at least it's BuffERManager doing it)
    if Flamelex.Buffer.Utils.OpenBuffer.open_this_buffer_in_gui?(buf_state) do
      #TODO maybe replace this with GUI.Controller.fire_action({:show, buf}) - it' more consistent with the rest of flamelex, and then we dont need to keep adding new interface functions inside gui controller
      GenServer.cast(Flamelex.GUI.Controller, {:show, buf_state})
    end

    {:noreply, %{state|buffer_list: state.buffer_list ++ [buf_state.rego_tag], active_buffer: buf_state.rego_tag}}
  end

  # #TODO need to give each buffer a new number...
  def handle_cast({:close, buf}, state) do
    # if state |> Enum.member?(buf) do
    #   #TODO this needs cleanup...
    #   case ProcessRegistry.find_buffer(buf) do
    #     pid when is_pid(pid) ->
    #         pid |> GenServer.cast(:close)
    #         new_state = state |> Enum.reject(& &1 == buf)
    #         {:reply, :ok, new_state}
    #     {:ok, pid} ->
    #         pid |> GenServer.cast(:close)
    #         new_state = state |> Enum.reject(& &1 == buf)
    #         {:reply, :ok, new_state}
    #     {:error, reason} ->
    #         {:reply, {:error, "not an open buffer: " <> reason}, state}
    #   end
    # else
    #   {:reply, {:error, "not an open buffer"}, state}
    # end

    #TODO remove from the list of buffers, and remove from active buffer if that was the active buffer

    #TODO talk to the other process & say hey close plz

    ProcessRegistry.find!(buf)
    |> GenServer.cast(:close)

    {:noreply, state}

  end

  # @impl true
  # def handle_info({:active_buffer, :switch_mode, _new_mode}, %{active_buffer: nil} = state) do
  #   IO.puts "Cannot switch to a new mode sine we don't have an active buffer"
  #   {:noreply, state}
  # end

  # def handle_info({:active_buffer, :switch_mode, new_mode}, %{active_buffer: %{ref: ref} = active_buf} = state) do

  #   #TODO just broadcast to the :gui_update_bus
  #   ProcessRegistry.find!({:gui_component, ref})
  #   # Flamelex.GUI.Component.TextBox.rego_tag(active_buf)
  #   # |> ProcessRegistry.find!()
  #   |> send({:switch_mode, new_mode})


  #   #TODO look up the gui component & send it a msg to switch modes

  #   #TODO2 just get GUI Controller to do it for us...

  #   {:noreply, state}
  # end

  # when new actions are published to the `:action_event_bus`,
  # this is where BufferManager receives them
  def handle_info(%{action: action, radix_state: radix_state}, bufr_mgr_state) do

    Flamelex.Fluxus.Reducers.Buffer.handle(%{
      radix_state: radix_state,
      bufr_mgr_state: bufr_mgr_state,
      action: action
    })

    {:noreply, bufr_mgr_state}
  end

  ##TODO very good maintenance check
  # this process should periodically check the children under Buffer Supervisor,
  # and see which ones are supposed to be open, and try to end the ones that shouldn't be open
end
