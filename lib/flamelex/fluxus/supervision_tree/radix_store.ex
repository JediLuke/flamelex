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
    #TODO whiteboard, comms/`switchboard`, :workbench
  ]

  #   #HUGE IDEA 2 - the GUI.Component and the Buffer.Component have a shared
#   #              state, via an Agent process!!
#   #              They receive an action, they go fetch the state, they
#   #              can lock it if needed (call), and they can process it.
#   #              If the state changes, then act of changing it can
#   #              publish a msg to other listeners (i.e. the GUI.Component)
#   #              who will have to re-render their shit.


  @default_menu_map [
      {"Flamelex",
          [
              {"temet nosce", &Flamelex.temet_nosce/0},
              #  {"show cmder", &Flamelex.API.Memex.close/0},
              #DevTools
          ]},
      {"Buffer",
          [
              {"new", &Flamelex.API.Buffer.new/0},
              #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
              {"save", &Flamelex.API.Buffer.save/0},
              {"close", &Flamelex.API.Buffer.close/0}
          ]},
      {"Memex",
          [
              {"open", &Flamelex.API.Memex.open/0},
              {"close", &Flamelex.API.Memex.close/0},
              # random
              # journal
          ]}
      # {"Help", [
      # GettingStarted
      # {"About QuillEx", &Flamelex.API.Misc.makers_mark/0}]},
      ]

  @fluxus_radix %{
    root: %{
      active_app: :desktop,
      mode: :normal,
      # TODO: [WindowArrangement.single_pane()], # A list of layers, which are in turn, lists of %WindowArrangement{} structs
      graph: nil, # This holds the layers construct
      layers: [ # The final %Graph{} which we are holding on to for, for each layer
        #NOTE: We use a Keyword list, as it works better for pattern matching than maps with keys
        one: nil,
        two: nil,
        three: nil,
        four: nil
      ]
    },
    gui: %{
      viewport: nil,
      theme: Flamelex.GUI.Utils.Theme.default(),
      font_metrics: nil
    },
    menu_bar: %{
      height: 60,
      menu_map: @default_menu_map,
      font: %{name: :ibm_plex_mono, size: 36},
      sub_menu: %{
        height: 40,
        font: %{name: :ibm_plex_mono, size: 22}
      }
    },
    desktop: %{
      graph: nil,
    },
    editor: %{
      graph: nil,
      buffers: [], # A list of %Buffer{} structs
      active_buf: nil,
      config: %{
        keymap: Flamelex.API.KeyMappings.VimClone
      },
    },
    memex: %{
      graph: nil, # Store the %Graph{} here if we need to (for switching between apps easily)
      active?: Application.get_env(:memelex, :active?), # If the Memex is disabled at the app config level, we need to ignore a lot of actions
      story_river: %{
        open_tidbits: [],
        #TODO put the scroll in another process, then it a) will hopefully be more seperated and b) we can just update that one (maybe even just by calling update_opts) and don't have to re-render every component we're scrolling, which is kinda crazy
        scroll: %{
          accumulator: {0, 0},
          direction: :vertical,
          components: [],
          #acc_length: nil # this will get populated by the component, and will accumulate as TidBits get put in the StoryRiver 
        }
      },
      sidebar: %{
        active_tab: :ctrl_panel,
        search: %{
          active?: false,
          string: ""
        }
      }
    },
    workbench: %{
      graph: nil,
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
  def initialize(graph: new_graph, layers: layers, viewport: new_viewport) do
    Agent.update(__MODULE__, fn old ->

      {:ok, ibm_plex_mono_metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

      new_root = old.root
                 |> Map.put(:graph, new_graph)
                 |> Map.put(:layers, layers)
      new_gui  = old.gui
                 |> Map.put(:viewport, new_viewport)
                 |> Map.put(:font_metrics, %{ibm_plex_mono: ibm_plex_mono_metrics})
      
      old |> Map.merge(%{root: new_root, gui: new_gui})
    end)
  end

  def broadcast_update(new_state) do
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
