defmodule Flamelex.GUI.Structs.Frame do
  @moduledoc """
  Struct which holds relevant data for rendering a buffer frame status bar.
  """
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.BufRef
  alias Flamelex.GUI.Structs.GUIState

  #TODO each "new/x" function should be making a new Scenic.Graph, we need
  # to actually build one and cant just use a default struct cause it spits chips

  defstruct [
    #TODO change top_left to `pin` (this would then be awesome to add an 'orientation' flag, which would default to scenic default, :top_left)
    top_left:     nil,            # a %Coordinates{} struct, pointing to the top-left corner of the frame, referenced from top-left corner of the viewport
    #TODO change dimensions to 'size' (or something better) - I dont think `dimens` is good
    dimensions:   nil,            # a %Dimensions{} struct, specifying the height and width of the frame
    margin: %{
        top: 0,
        right: 0,
        bottom: 0,
        left: 0 },
    # scenic_opts:  [],             # Scenic options
    label:        nil             # an optional label, usually used to render a footer bar
  ]

  # def test do
  #   new("tester", {100, 100}, {100, 100})
  # end

  # def new(label, %Coordinates{} = c, %Dimensions{}  = d) do
  #   new(
  #     id:              label,
  #     top_left_corner: %Coordinates{} = c,
  #     dimensions:      %Dimensions{}  = d
  #   )
  # end
  # def new(label, coords, dimensions) do
  #   new(label, Coordinates.new(coords), Dimensions.new(dimensions))
  # end

  def calculate_frame_position(%{show_menubar?: true}) do
    Coordinates.new(x: 0, y: Flamelex.GUI.Component.MenuBar.height())
  end
  def calculate_frame_position(_otherwise) do
    Coordinates.new(x: 0, y: 0)
  end
  #   case opts |> Map.fetch(:show_menubar?) do
  #     {:ok, true} ->
        
  #     _otherwise ->
        
  #   end
  # end

  #TODO lol whats going on here
  def calculate_frame_size(opts, layout_dimens) do
    case opts |> Map.fetch(:show_menubar?) do
      {:ok, true} ->
        Dimensions.new(width: layout_dimens.width, height: layout_dimens.height)
      _otherwise ->
        Dimensions.new(width: layout_dimens.width, height: layout_dimens.height)
    end
  end



  def new(%Scenic.ViewPort{size: {w, h}}) do
    Logger.debug "constructing a new %Frame{} the size of the ViewPort."
    %Frame{
      top_left: Coordinates.new(x: 0, y: 0),
      dimensions: Dimensions.new(width: w, height: h)
    }
  end

  def new([pin: {x, y}, size: {w, h}]) do
    %Frame{
      top_left: Coordinates.new(x: x, y: y),
      dimensions: Dimensions.new(width: w, height: h)
    }
  end

  def new([pin: %{x: x, y: y}, size: {w, h}]) do
    %Frame{
      top_left: Coordinates.new(x: x, y: y),
      dimensions: Dimensions.new(width: w, height: h)
    }
  end


  # def new(
  #       %{
  #         layout: %Layout{
  #           arrangement: :maximized,
  #           dimensions: %Dimensions{} = layout_dimens,
  #           frames: [], #NOTE: No existing frames
  #           opts: opts
  #         }},
  #       buf_tag) do
  def new(
    top_left:     %Coordinates{} = c,
    dimensions:   %Dimensions{}  = d
  ) do
    %__MODULE__{
      top_left:   c,
      dimensions: d
    }
  end

  def new(gui_state, buf_tag) do
  # def new(%GUIState{} = gui_state, buf_state) do
    

    coords = calculate_frame_position(gui_state)
    # dimens = calculate_frame_size(opts, layout_dimens)

    # coords = {50, 50}|> Coordinates.new()
    # dimens = {400, 400}|> Dimensions.new()
    %__MODULE__{
      top_left:   coords,
      dimensions: gui_state.viewport,
      label: "#{File.cwd!()}/example.txt"
    }
  end



  def new(
    top_left:     %Coordinates{} = c,
    dimensions:   %Dimensions{}  = d
  ) do
    %__MODULE__{
      top_left:   c,
      dimensions: d
    }
  end

  def new(top_left: top_left, size: size) do
    %__MODULE__{
      top_left:   top_left |> Coordinates.new(),
      dimensions: size     |> Dimensions.new()
    }
  end

  def new(top_left: {_x, _y} = c, dimensions: {_w, _h} = d) do
    %__MODULE__{
      top_left:   c |> Coordinates.new(),
      dimensions: d |> Dimensions.new()
    }
  end

  def new(top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d) do
    %__MODULE__{
      top_left:   c |> Coordinates.new(),
      dimensions: d |> Dimensions.new()
    }
  end

# def new(top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d, opts: o)  when is_list(o) do
#     %Frame{
#       top_left:     c |> Coordinates.new(),
#       dimensions:   d |> Dimensions.new(),
#       scenic_opts:  o
#     }
#   end

  def set_margin(frame, %{top: t, left: l}) do
      %{frame|
          margin: %{
            top: t,
            right: 0,
            bottom: 0,
            left: l
          }
      }
  end

  def draw_frame_footer(
        %Scenic.Graph{} = graph,
        %{ frame: %Frame{} = frame,
           draw_footer?: true })
  do

    w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
    h = Flamelex.GUI.Component.MenuBar.height()
    x = frame.top_left.x
    y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
    c = Flamelex.GUI.Colors.menu_bar()

    # font_size = Flamelex.GUI.Fonts.size()
    font_size = 24 #TODO
    mode_textbox_width = 250

    stroke_width = 2
    mode_string = "NORMAL_MODE"
    left_margin = 25

    frame_label = if frame.label == nil, do: "", else: frame.label

    graph
    # first, draw the background
    |> Scenic.Primitives.rect({w, h},
                translate:  {x, y},
                fill:       c)
    # then, draw the backgrounnd rectangle for the mode-string box
    |> Scenic.Primitives.rect({mode_textbox_width, h},
                id: :mode_string_box,
                translate:  {x, y},
                fill:       Flamelex.GUI.Colors.mode(:normal))
    # draw the text showing the mode_string
    |> Scenic.Primitives.text(mode_string,
                id: :mode_string,
                # font:       Flamelex.GUI.Fonts.primary(),
                font:       :ibm_plex_mono,
                translate:  {x+left_margin, y+font_size+stroke_width}, # text draws from bottom-left corner??
                font_size:  font_size,
                fill:       :black)
    # draw the text showing the frame_label
    |> Scenic.Primitives.text(frame_label,
                # ont:       Flamelex.GUI.Fonts.primary(),
                font:       :ibm_plex_mono,
                translate:  {x+mode_textbox_width+left_margin, y+font_size+stroke_width}, # text draws from bottom-left corner??
                font_size:  font_size,
                fill:       :black)
    # draw a simple line above the frame footer
    |> Scenic.Primitives.line({{x, y}, {w, y}},
                stroke:     {stroke_width, :black})
  end

  def draw_frame_footer(%Scenic.Graph{} = graph, _params) do
    #NOTE: do nothing, as we didn't match on the correct frame_opts
    graph
  end

  def decorate_graph(%Scenic.Graph{} = graph, %{frame: %Frame{} = frame} = params) do
    Logger.debug "#{__MODULE__} framing up... frame: #{inspect frame}, params: #{inspect params}"
    Logger.warn "Not rly framing anything yet..."
    graph
  end

  def find_center(%__MODULE__{top_left: c, dimensions: d}) do
    Coordinates.new([
      x: c.x + d.width/2,
      y: c.y + d.height/2,
    ])
  end

  def reposition(%__MODULE__{top_left: coords} = frame, x: new_x, y: new_y) do
    new_coordinates =
      coords
      |> Coordinates.modify(x: new_x, y: new_y)

    %{frame|top_left: new_coordinates}
  end

  def resize(%__MODULE__{dimensions: dimens} = frame, reduce_height_by: h) do
    new_height = frame.dimensions.height - h

    new_dimensions =
      dimens |> Dimensions.modify(
                      width: frame.dimensions.width,
                      height: new_height )

    %{frame|dimensions: new_dimensions}
  end

  # def draw(%Scenic.Graph{} = graph, %Frame{} = frame) do
  #   graph
  #   |> Draw.border_box(frame)
  #   |> draw_frame_footer(frame)
  # end

  # def draw(%Scenic.Graph{} = graph, %Frame{} = frame, opts) when is_map(opts) do
  #   graph
  #   |> draw_frame_footer(frame, opts)
  #   |> Draw.border_box(frame)
  # end

  # def draw(%Scenic.Graph{} = graph, %Frame{} = frame, %Flamelex.Fluxus.Structs.RadixState{} = radix_state) do
  #   graph
  #   |> draw_frame_footer(frame, radix_state)
  #   |> Draw.border_box(frame)
  # end

  # def draw_frame_footer(graph, frame, %{mode: :normal} = opts) when is_map(opts) do
  #   w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
  #   h = Flamelex.GUI.Component.MenuBar.height()
  #   x = frame.top_left.x
  #   y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
  #   c = Flamelex.GUI.Colors.menu_bar()

  #   font_size = Flamelex.GUI.Fonts.size()

  #   graph
  #   |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
  #   |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: Flamelex.GUI.Colors.mode(:normal))
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.text("NORMAL-MODE", font: Flamelex.GUI.Fonts.primary(),
  #               translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  #   |> Scenic.Primitives.text(frame.id, font: Flamelex.GUI.Fonts.primary(), #TODO should be frame.name ??
  #               translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  # end


  # def draw_frame_footer(graph, frame, %{mode: :insert} = opts) when is_map(opts) do
  #   w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
  #   h = Flamelex.GUI.Component.MenuBar.height()
  #   x = frame.top_left.x
  #   y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
  #   c = Flamelex.GUI.Colors.menu_bar()

  #   font_size = Flamelex.GUI.Fonts.size()

  #   graph
  #   |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
  #   |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: Flamelex.GUI.Colors.mode(:insert))
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.text("INSERT-MODE", font: Flamelex.GUI.Fonts.primary(),
  #               translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  #   |> Scenic.Primitives.text(frame.id, font: Flamelex.GUI.Fonts.primary(), #TODO should be frame.name ??
  #               translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  # end

  # def draw_frame_footer(graph, frame) do
  #   w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
  #   h = Flamelex.GUI.Component.MenuBar.height()
  #   x = frame.top_left.x
  #   y = frame.dimensions.height # go to the bottom & back up how high the bar will be
  #   c = Flamelex.GUI.Colors.menu_bar()

  #   graph
  #   |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
  # end

  # def draw_frame_footer(graph, frame, %Flamelex.Fluxus.Structs.RadixState{mode: :normal}) do
  #   w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
  #   h = Flamelex.GUI.Component.MenuBar.height()
  #   x = frame.top_left.x
  #   y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
  #   c = Flamelex.GUI.Colors.menu_bar()

  #   font_size = Flamelex.GUI.Fonts.size()

  #   graph
  #   |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
  #   |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: Flamelex.GUI.Colors.mode(:normal))
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
  #   |> Scenic.Primitives.text("NORMAL-MODE", font: Flamelex.GUI.Fonts.primary(),
  #               translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  #   |> Scenic.Primitives.text(frame.id, font: Flamelex.GUI.Fonts.primary(), #TODO should be frame.name ??
  #               translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
  #               font_size: font_size, fill: :black)
  # end
end










# defmodule Flamelex.GUI.Component.Frame do
#   @moduledoc """
#   Frames are a very special type of Component - they are a container,
#   manipulatable by the layout of the root scene. Virtually all buffers
#   will render their corresponding Component in a Frame.
#   """

#   use Scenic.Component
#   use Flamelex.ProjectAliases
#   require Logger


#   @impl Scenic.Component
#   def verify(%Frame{} = frame), do: {:ok, frame}
#   def verify(_else), do: :invalid_data

#   @impl Scenic.Component
#   def info(_data), do: ~s(Invalid data)


#   ## GenServer callbacks
#   ## -------------------------------------------------------------------


#   @impl Scenic.Scene
#   def init(%Frame{} = frame, _opts) do
#     # IO.puts "Initializing #{__MODULE__}..."
#     {:ok, frame, push: GUI.GraphConstructors.Frame.convert(frame)}
#   end

#   # left-click
#   def handle_input({:cursor_button, {:left, :press, _dunno, _coords}} = action, _context, frame) do
#     # new_frame = frame |> ActionReducer.process(action)
#     new_graph = frame |> GUI.GraphConstructors.Frame.convert_2()
#     {:noreply, frame, push: new_graph}
#   end

#   def handle_input(event, _context, state) do
#     # state = Map.put(state, :contained, true)
#     IO.puts "EVENT #{inspect event}"
#     # {:noreply, state, push: update_color(state)}
#     {:noreply, state}
#   end

#   # def filter_event(event, _, state) do
#   #   IO.puts "EVENT #{event}"
#   #   {:cont, {:click, :transformed}, state}
#   # end

#   # def handle_continue(:draw_frame, frame) do


#   #   new_graph =
#   #     frame.graph
#   #     |> Draw.box(
#   #             x: frame.top_left.x,
#   #             y: frame.top_left.y,
#   #         width: frame.width,
#   #        height: frame.height)

#   #   new_frame =
#   #     %{frame|graph: new_graph}

#   #   {:noreply, new_frame}
#   #   # {:noreply, new_frame, push: new_graph}
#   # end



#   ## private functions
#   ## -------------------------------------------------------------------


#   # defp register_process() do
#   #   #TODO search for if the process is already registered, if it is, engage recovery procedure
#   #   Process.register(self(), __MODULE__) #TODO this should be gproc
#   # end

#   # def initialize(%Frame{} = frame) do
#   #   # the textbox is internal to the command buffer, but we need the
#   #   # coordinates of it in a few places, so we pre-calculate it here
#   #   textbox_frame =
#   #     %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

#   #   Draw.blank_graph()
#   #   |> Scenic.Primitives.group(fn graph ->
#   #        graph
#   #        |> Draw.background(frame, @command_mode_background_color)
#   #        |> DrawingHelpers.draw_command_prompt(frame)
#   #        |> DrawingHelpers.draw_input_textbox(textbox_frame)
#   #        |> DrawingHelpers.draw_cursor(textbox_frame, id: @cursor_component_id)
#   #        |> DrawingHelpers.draw_text_field("", textbox_frame, id: @text_field_id) #NOTE: Start with an empty string
#   #   end, [
#   #     id: @component_id,
#   #     hidden: true
#   #   ])
#   # end


#   # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c) do
#   #   Graph.build()
#   #   |> rect({w, h}, translate: {x, y}, fill: c)
#   # end
#   # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c, stroke: {s, border_color}) do
#   #   Graph.build()
#   #   |> rect({w, h}, translate: {x, y}, fill: c, stroke: {s, border_color})
#   # end
# end
