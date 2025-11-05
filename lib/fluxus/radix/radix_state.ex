defmodule Flamelex.Fluxus.RadixState do
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
  <!-- If we don't need to alter anything at this level, then do not implement -->
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
  use StructAccess
  alias Flamelex.GUI.Layers.{Layer01, Layer2, Layer3, Layer4}

  alias Flamelex.GUI.Component.{
    QlxWrap,
    TODOlist,
    TODOdetails,
    RapidSelector,
    HighCouncil,
    AgentHuddle,
    Kommander
  }

  # On the concept of breaking up Radix state
  # If I do another iteration of RadixStore, I will have this process accept actions
  # and have it contain a minimal, "top layer" state - changes to the top layer, may
  # propagate down through various other layers, but we route actions down to the state
  # process which consumes them. This process then fires off updates (potentially). So
  # if I type a new letter and the active buffer gets it, processes the input and adds
  # another character to the line - the fact that this update took place is broadcast

  # the argument for using radix struct is that I can pattern match on exactly a radix state
  # the argument against is that I might want to dynamically add keys to it...
  defstruct menubar: nil,
            # popup_modal: nil,
            memex: nil,
            fonts: nil,
            layers: nil,
            apps: nil,
            # gui: nil,
            history: %{
              keystrokes: []
            }

#       projects: %{
#         open_proj: nil,
#         proj_list: []
#       },

  def new() do
    
    # rdx =
      %__MODULE__{
        layers: %{
          one: Layer01.State.new(),
          two: %{
            menubar: %{
              font: :ibm_plex_mono,
              height: 60
            }
          },
          three: Layer3.State.new(),
          four: Layer4.State.new()
        },
        apps: %{
          qlx_wrap: QlxWrap.State.new(),
          todo_list: TODOlist.State.new(),
          kommander: Kommander.State.new(),
          todo_details: TODOdetails.State.new(),
          high_council: HighCouncil.State.new(query_memex?: false),
          agent_huddle: AgentHuddle.State.new(),
          rapid_selector: RapidSelector.State.new()
        },
        memex: new_radix_memex_state(),
        fonts: fonts(),
      }

    # # need to calculate Layer2 state last because that requires radix state as an input (MenuBar changes if we have open buffers etc)
    # layer_2 = Layer2.State.new(rdx)

    # rdx
    # |> put_in([:layers, :two], layer_2)
  end

  def new_radix_memex_state() do
    case Memelex.environment_details() do
      %Memelex.Environment{} = env ->
        %{
          active?: true,
          env: env,
          open_memex_popup_open?: false
        }

      _otherwise ->
        %{
          active?: false,
          env: nil,
          open_memex_popup_open?: false
        }
    end
  end

  # def theme do
  #   Scenic.Primitive.Style.Theme.preset(:light)
  #   |> Scenic.Primitive.Style.Theme.normalize()
  # end

  def fonts do
    # TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")
    {:ok, ibm_plex_mono_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    {:ok, noto_sans_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf")

    {:ok, meroitic_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf")

    %{
      ibm_plex_mono: %{
        metrics: ibm_plex_mono_font_metrics
      },
      noto_sans: %{
        metrics: noto_sans_font_metrics
      },
      meroitic: %{
        metrics: meroitic_font_metrics
      }
    }
  end
end
