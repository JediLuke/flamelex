defmodule Flamelex.GUI.StageManager.Memex do
  @moduledoc """
  This process holds state for when we use Vim commands.
  """
  use GenServer
  use Flamelex.ProjectAliases
  require Logger


  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    Logger.debug "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, %{open: []}}
  end

  def handle_cast(:memex_open, %{open: []} = state) do
    Logger.debug "#{__MODULE__} recv'd: :memex_open"
    {:noreply, state}
  end

  def handle_cast(:open_random_tidbit, state) do
        # t = Memex.random()
    # # GenServer.cast(:hypercard, {:new_tidbit, t})
    # GenServer.cast(Flamelex.GUI.Component.Memex.HyperCard, {:new_tidbit, t})
    Logger.debug "#{__MODULE__} recv'd msg: :open_random_tidbit"
    t = Memex.My.Wiki.list |> Enum.random()
    new_state = %{state|open: state.open ++ [t]}
    GenServer.cast(Flamelex.GUI.Component.Memex.StoryRiver, {:add_tidbit, t})
    {:noreply, new_state}
  end

  def handle_cast({:open_tidbit, t}, state) do
    Logger.debug "#{__MODULE__} recv'd msg: {:open_random, #{t.title}}"
    new_state = %{state|open: state.open ++ [t]}
    GenServer.cast(Flamelex.GUI.Component.Memex.StoryRiver, {:add_tidbit, t})
    {:noreply, new_state}
  end

  def handle_call(:get_open_tidbits, _from, %{open: []} = state) do
    Logger.warn "Dont wanna open empty Memex yet lol, just render a rando..."
    #TODO fix the bug vacarsu found here
    case Memex.My.Wiki.list() do
      [] ->
        Logger.warn "WE SHOULD just always make at least one thing in the Meme..."
        {:reply, {:ok, []}, state}
      [_t|_rest] ->
        rando = Memex.My.Wiki.list |> Enum.random()
        {:reply, {:ok, [rando]}, %{state|open: [rando]}}
    end
  end

end
