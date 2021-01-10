
defmodule Flamelex.BufferManager do
  @moduledoc """
  Coordinates & administrates all the open buffers.
  """
  use GenServer
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.Structs.Buf
  alias Flamelex.Buffer.BufUtils

  #TODO if a buffer crashes, need to catch it & alert Flamelex.GUI.Controller
  #TODO idea: the GUI should turn grey, with an x through it - but it has memory (text etc) in it - maybe it can be used to recover the Buffer state...

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    PubSub.subscribe(topic: :active_buffer)
    {:ok, %{buffer_list: [], active_buffer: nil}}
  end

  #TODO maybe it's not safe to have this exposed?? Anyone can call & crash the Manager??
  def handle_call({:open_buffer, params}, _from, state) do
    # 1) way of registering processes / # 2) a system for doing that
    # 3) a PubSub which works, which goes heirarchically, and the top level can be some reference like "lukes_journal", so it's easy to broadcast to all processes which need updates about my journal
    case BufUtils.open_buffer(params) do
      {:ok, %Buf{} = buf} ->
          if BufUtils.open_this_buffer_in_gui?(params) do
            :ok = Flamelex.GUI.Controller.show(buf)
          end
          {:reply, {:ok, buf}, %{state|buffer_list: state.buffer_list ++ [buf], active_buffer: buf}}
      {:error, reason} ->
          {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:find_buffer, search_term}, _from, state) do

    similarity_cutoff = 0.72 # used to compare how similar the strings are

    find_buf =
      state
      |> Enum.find(
           :no_matching_buffer_found, # this is the default value we return if no element is found by the function below
           fn %Buf{} = b ->
             # TheFuzz.compare(:jaro_winkler, search_term, b.label) >= similarity_cutoff
             String.jaro_distance(search_term, b.label) >= similarity_cutoff
           end)

    case find_buf do
      :no_matching_buffer_found ->
        {:reply, {:error, "no matching buffer found"}, state}
      %Buf{} = buf ->
        {:reply, {:ok, buf}, state}
    end
  end

  def handle_call(:count_buffers, _from, state) do
    count = Enum.count(state)
    {:reply, count, state}
  end

  def handle_call(:list_buffers, _from, state) do
    {:reply, state, state}
  end

  # #TODO need to give each buffer a new number...
  # def handle_call({:close_buffer, buf}, _from, state) do
  #   if state |> Enum.member?(buf) do
  #     #TODO this needs cleanup...
  #     case ProcessRegistry.find_buffer(buf) do
  #       pid when is_pid(pid) ->
  #           pid |> GenServer.cast(:close)
  #           new_state = state |> Enum.reject(& &1 == buf)
  #           {:reply, :ok, new_state}
  #       {:ok, pid} ->
  #           pid |> GenServer.cast(:close)
  #           new_state = state |> Enum.reject(& &1 == buf)
  #           {:reply, :ok, new_state}
  #       {:error, reason} ->
  #           {:reply, {:error, "not an open buffer: " <> reason}, state}
  #     end
  #   else
  #     {:reply, {:error, "not an open buffer"}, state}
  #   end
  # end

  @impl true
  def handle_info({:active_buffer, :switch_mode, _new_mode}, %{active_buffer: nil} = state) do
    IO.puts "Cannot switch to a new mode sine we don't have an active buffer"
    {:noreply, state}
  end

  def handle_info({:active_buffer, :switch_mode, new_mode}, %{active_buffer: %Buf{ref: ref} = active_buf} = state) do

    ProcessRegistry.find!({:gui_component, ref})
    # Flamelex.GUI.Component.TextBox.rego_tag(active_buf)
    # |> ProcessRegistry.find!()
    |> IO.inspect(label: "gui component pid")
    |> send({:switch_mode, new_mode})


    #TODO look up the gui component & send it a msg to switch modes

    #TODO2 just get GUI Controller to do it for us...

    {:noreply, state}
  end
end
