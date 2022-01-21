defmodule Flamelex.Fluxus.RadixStore do
  @moduledoc """
  This module just stores the actual state itself - modifications are
  made elsewhere.

  https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/
  """
  use Agent
  require Logger

  @valid_apps [
    :desktop,     # The default screen, a personalized "homepage"
    :editor,      # The text-editor interface
    :memex        # The memex screen
  ]

  @fluxus_radix %{
    root: %{
      active_app: :desktop,
      mode: :normal,
      graph: nil, # The final %Graph{} which we are holding on to for 
    },
    gui: %{
      viewport: nil,
      layers: nil,
      # layers: [WindowArrangement.single_pane()], # A list of layers, which are in turn, lists of %WindowArrangement{} structs
      theme: Flamelex.GUI.Utils.Theme.default()
    },
    desktop: %{},
    editor: %{
      buffers: [], # A list of %Buffer{} structs
      active_buf: nil,
      config: %{
        keymap: Flamelex.API.KeyMappings.VimClone
      },
    },
    memex: %{
      active?: Application.get_env(:memelex, :active?),
      graph: nil, # Store the %Graph{} here if we need to (for switching between apps easily)
      sidebar: %{
        active_tab: :open_tidbits,
        search: %{
          active?: false,
          string: ""
        }
      }
    },
    history: %{
      keystrokes:   [],
      actions:      []
    }
  }


  def start_link(_params) do
    Agent.start_link(fn -> @fluxus_radix end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  #NOTE: When `Flamelex.GUI.RootScene` boots, it calls this function
  #      to reset the values of `graph` and `viewport`.
  #      We don't want to broadcast these changes out.
  def initialize(graph: new_graph, viewport: new_viewport) do
    Agent.update(__MODULE__, fn old ->
      new_root = old.root |> Map.put(:graph, new_graph)
      new_gui  = old.gui |> Map.put(:viewport, new_viewport)
      
      old |> Map.merge(%{root: new_root, gui: new_gui})
    end)
  end

  def broadcast(new_state) do
    Logger.debug("#{__MODULE__} updating state & broadcasting new_state...")
    #Logger.debug("#{__MODULE__} updating state & broadcasting new_state: #{inspect(new_state)}")

    # NOTE: Although I did try it, I decided not to go with using the
    #      event bus for updating the GUI due to a state change. The event-
    #      bus serves it's purpose for funneling all action through one
    #      choke-point, and keeps track of them etc, but just pushing
    #      updates to the GUI is simpler when done via a PubSub (no need to acknowledge
    #      events as complete), and easier to implement, since the EventBus
    #      lib we're using receives events in a separate process to the
    #      one where we actually declared the function. We could forward
    #      the state updates on to each ScenicComponent, but then we
    #      start to have problems of how to handle addressing... the
    #      exact problem that PubSub is a perfect solution for.
    Flamelex.Utils.PubSub.broadcast(
        topic: :radix_state_change,
        msg: {:radix_state_change, new_state})

    Agent.update(__MODULE__, fn _old -> new_state end)
  end
end
