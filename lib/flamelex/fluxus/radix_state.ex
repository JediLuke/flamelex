defmodule Flamelex.Fluxus.Structs.RadixState do
  @moduledoc false
  use Flamelex.ProjectAliases


  #TODO eventually, remove this... maybe?
  use StructAccess # https://github.com/mbramson/struct_access

  @max_keystroke_history_limit 50

  @max_action_history_limit 50


  #TODO this struct definition isn't great, but at least now we have one
  defstruct [
    root: nil,
    gui: nil,
    fonts: nil,
    menu_bar: nil,
    kommander: nil,
    desktop: nil,
    editor: nil,
    memex: nil,
    workbench: nil,
    history: nil
  ]

  # defstruct [
  #   mode:                 :normal,    # The input mode
  #   active_buffer:        nil,        # We need to know the active buffer - must be a %Flamelex.Structs.BufRef{}
  #   keystroke_history:    [],         # A list of all previously entered user-input keystrokes
  #   action_history:       [],         # A history of actions sent to FluxusRadix
  #   inbox_buffer:         [],         # when an action happens, we may need to buffer further actions until that one finishes - they are buffered here. we do same for keystrokes, so it's `inbox` buffer, to cover all cases
  #   runtime_config:       %{
  #     keymap:             Flamelex.API.KeyMappings.Vim
  #   }
  # ]




  @valid_apps [
      :desktop,     # The default screen, a personalized "homepage"
      :editor,      # The text-editor interface
      :memex        # The memex screen
      #TODO whiteboard, comms/`switchboard`, :workbench
    ]

  @doc """
  This function calculates & returns the default RadixState - the one
  that is populated upon applications startup.  
  """
  def default do
    {:ok, ibm_plex_mono_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

    fonts_and_metrics = %{
      ibm_plex_mono: %{
        metrics: ibm_plex_mono_metrics # This gets loaded when we create a new RadixState
      }
    }

    default_fluxus_radix()
    |> put_in([:fonts], fonts_and_metrics)
  end


  def default_fluxus_radix do
    %__MODULE__{
      root: %{
        active_app: :desktop,
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
      },
      fonts: %{}, #TODO move this under :gui would probably be nicer...
      #TODO could also put all these apps under some `apps` key
      menu_bar: %{
        height: 60,
        menu_map: calc_menu_map(),
        font: %{name: :ibm_plex_mono, size: 36},
        sub_menu: %{
          height: 40,
          font: %{name: :ibm_plex_mono, size: 22}
        }
      },
      kommander: %{
        hidden?: true
      },
      desktop: %{
        graph: nil,
      },
      editor: %{
        graph: nil,
        buffers: [], # A list of %Buffer{} structs
        active_buf: nil,
        config: %{
          keymap: Flamelex.API.KeyMappings.Vim
        },
      },
      memex: %{
        graph: nil, # Store the %Graph{} here if we need to (for switching between apps easily)
        active?: Application.get_env(:memelex, :active?), # If the Memex is disabled at the app config level, we need to ignore a lot of actions
        story_river: %{
          open_tidbits: [],
          # mode: :read_only,
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
        # actions:      []
      }
    }
  end

  def calc_menu_map do
    [
      {"Flamelex",
          [
              {"temet nosce", &Flamelex.temet_nosce/0},
               {"show cmder", &Flamelex.API.Kommander.show/0},
               {"hide cmder", &Flamelex.API.Kommander.hide/0}
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
  end






  #TODO it should be possible to use the action/keystroke history to record macros


  # @modes [:normal, :insert, {:kommand_buffer_active, :insert}]




  # #TODO ok, figure out how modes is gonna work, with active buffer etc...
  # def set(%__MODULE__{} = radix_state, [mode: m]) when m in @modes do
  #   %{radix_state|mode: m}
  # end

  # def record(%__MODULE__{keystroke_history: keystroke_history} = radix_state, keystroke: %{input: k}) do
  #   new_keystroke_history =
  #       keystroke_history
  #       |> add_to_list(k, max_length: @max_keystroke_history_limit)

  #   %{radix_state|keystroke_history: new_keystroke_history}
  # end

  # def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
  #   updated_history =
  #     action_history
  #     |> add_to_list(a, max_length: @max_action_history_limit)

  #   %{radix_state|action_history: updated_history}
  # end

  # def set_active_buffer(%__MODULE__{} = radix_state, b) do
  #   %{radix_state|active_buffer: b}
  # end

  # def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
  #   new_action_history =
  #       action_history
  #       |> add_to_list(a, max_length: @max_action_history_limit)

  #   %{radix_state|action_history: new_action_history}
  # end

  # # def last_keystroke_was?(%__MODULE__{keystroke_history: [last|_rest]}, x)
  # #   when last == x do true end
  # # def last_keystroke_was?(%__MODULE__{keystroke_history: _hist}, _x), do: false

  # def add_to_list(list, x, max_length: max_list_length)
  # when length(list) >= max_list_length
  # do
  #   list_minus_one_item = # https://stackoverflow.com/questions/52319984/remove-last-element-from-list-in-elixir
  #     list
  #     |> Enum.reverse()
  #     |> tl()
  #     |> Enum.reverse()

  #   list_minus_one_item ++ [x]
  # end

  # def add_to_list(list, x, max_length: _max_list_length)
  # when length(list) >= 0
  # do
  #   list ++ [x]
  # end

  # def last_keystroke(%__MODULE__{keystroke_history: []}), do: nil
  # def last_keystroke(%__MODULE__{keystroke_history: hist}) when length(hist) > 0 do
  #   hist
  #   |> Enum.reverse()
  #   |> hd()
  # end




end
