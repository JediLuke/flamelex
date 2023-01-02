defmodule Flamelex.Fluxus.Structs.RadixState do
   @moduledoc """
   In latin, `fluxus` means "flow" and `radix` means "root". FluxusRadix
   is the root node in the state-tree of fluxus internally (now renamed
   to RadixState).

   The FluxusRadix holds the highest-level flamelex state, for example:

      - the active buffer
      - the system mode
      - the input history (both keystrokes, & actions)
      - it acts as a conduit for all user-input

   We need a single junction-point where all the data required to make
   decisions can be combined & acted upon - this is it.

   What belongs in the domain of RadixState? Anything which affects both
   buffers & GUI components. e.g. opening the Command buffer requires:

   * changing the input mode
   * checking the contents of `Flamelex.Buffer.Command`
   * rendering the GUI.Component
   * etc...

   changing the input mode alone requires that we make our changes at the
   FluxusRadix level, so we might as well just put the rest as side-effects
   in the reducer at this level. This makes sense because it's a heirarchy -
   since we need to change the input it's an FluxusRadix level change, so
   the function to open the Command buffer must be implemented at this level.
   If we don't need to alter anything at this level, then do not implement
   it in a reducer/handler at this level, handle it somewhere lower.

   When we need to trigger something at the Radix level, we can use actions.
   Actions get handled by the TansStatum module, though the actual processing
   occurs in a seperate process, running under the
   `Flamelex.Fluxus.HandleAction.TaskSupervisor`.

   User input also gets funneled through this process - the RadixState (which
   includes the user-input history) and the input itself are handled by
   one of the InputHandler functions, which operate in basically the same
   manner as reducers - spun up into their own process & handled in there.
   Inputs usually lead to an action being dispatched, which is sent back
   to FluxusRadix (kind of a loop-back) to be then handled.
   """

   use Flamelex.ProjectAliases

   @max_keystroke_history_limit 50
   @max_action_history_limit 50


   @doc """
   This function calculates & returns the default RadixState - the one
   that is populated upon applications startup.  
   """
   def initialize do
      {:ok, ibm_plex_mono_font_metrics} =
         TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

      #TODO initialize the whole all with some default layer states

      %{
         root: %{
            active_app: :desktop,
            # active_app: :renseijin,
            graph: nil, # This holds the layers construct
            layers: %{
               one: %{
                  layout: %{
                     editor: :full_screen
                  }
               }
            }
            # layers: [ # The final %Graph{} which we are holding on to for, for each layer
            #    #NOTE: We use a Keyword list, as it works better for pattern matching than maps with keys
            #    one: nil,
            #    two: nil,
            #    three: nil,
            #    four: nil
            # ]
         },
         gui: %{
            viewport: nil,
            theme: Flamelex.GUI.Utils.Theme.default()
            # fonts: %{
            #    primary: ScenicWidgets.TextPad.Structs.Font.new(%{
            #       name: :ibm_plex_mono,
            #       metrics: ibm_plex_mono_font_metrics
            #    })
            # }
         },
         desktop: %{
            renseijin: %{
               visible?: true,
               animate?: false
             },
         },
         #TODO move this into desktop...
         menu_bar: %{
            font: :ibm_plex_mono,
            height: 60,
            show?: true,
            font_size: 36,
            sub_menu: %{
               height: 40,
               font_size: 22
            }
         },
         projects: %{
            open_proj: nil,
            proj_list: []
         },
         editor: %{
            font: ScenicWidgets.TextPad.Structs.Font.new(%{
               name: :ibm_plex_mono,
               metrics: ibm_plex_mono_font_metrics,
               size: 24
            }),
            graph: nil,
            buffers: [], # A list of %Buffer{} structs
            active_buf: nil,
            config: %{
               keymap: Flamelex.KeyMappings.Vim,
               scroll: %{
                  # invert: %{ # change the direction of scroll wheel
                  #   horizontal?: true,
                  #   vertical?: false
                  # },
                  speed: %{ # higher value means faster scrolling
                    horizontal: 5,
                    vertical: 3
                  }
               }
            }
         },
         kommander: %{
            hidden?: true,
            buffer: QuillEx.Structs.Buffer.new(%{
               id: {:buffer, Kommander},
               type: :text,
               data: "",
               mode: :edit
            }),
            font: ScenicWidgets.TextPad.Structs.Font.new(%{
               name: :ibm_plex_mono,
               metrics: ibm_plex_mono_font_metrics,
               size: 24
            })
         },
         memex: %{
            active?: Application.get_env(:memelex, :active?), # If the Memex is disabled at the app config level, we need to ignore a lot of actions
            story_river: %{
               open_tidbits: [],
               #TODO put the scroll in another process, then it a) will hopefully be more seperated and b) we can just update that one (maybe even just by calling update_opts) and don't have to re-render every component we're scrolling, which is kinda crazy
               scroll: {0, 0}
            },
            sidebar: %{
               active_tab: :ctrl_panel,
               search: %{
                  active?: false,
                  string: ""
               }
            }
         },
         # widget_wkb: %{
         #    graph: nil,
         # },
         history: %{
            keystrokes:   [],
            # actions:      []
         }
      }
   end


   # defdelegate change_font(radix_state, new_font),
   #    to: QuillEx.Fluxus.Structs.RadixState

   # defdelegate change_font_size(radix_state, direction),
   #    to: QuillEx.Fluxus.Structs.RadixState

   # defdelegate change_editor_scroll_state(radix_state, new_scroll_state),
   #    to: QuillEx.Fluxus.Structs.RadixState


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
