defmodule GUI.Component.Frame do
  @moduledoc false
  use Scenic.Component
  # alias Scenic.Graph
  # import Scenic.Primitives
  use Flamelex.CommonDeclarations
  require Logger


  @impl Scenic.Component
  def verify(%Frame{} = frame), do: {:ok, frame}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)


  # def show
  # def hide
  # def move


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def init(%Frame{} = frame, _opts) do
    Logger.info "Initializing #{__MODULE__}..."
    # register_process()

    bar_height = 24

    new_graph =
      Scenic.Graph.build()
      # draw header & footer before frame to get a nice "window" appearance
      |> draw_header_bar(frame, bar_height)
      |> draw_footer_bar(frame, bar_height)
      #TODO draw text in header bar
      |> Draw.border_box(frame)
      |> Draw.render_inner_buffer(frame, bar_height)

    # new_frame =
    #   %{frame|picture_graph: new_graph}

    Logger.info("#{__MODULE__} initialization complete.")

    {:ok, frame, push: new_graph}
  end

  defp draw_header_bar(graph, frame, height) do
    graph
    |> Scenic.Primitives.rect(
         {frame.dimensions.width, height}, [
            fill: :green,
            translate: {
              frame.coordinates.x,
              frame.coordinates.y}])
  end

  defp draw_footer_bar(graph, frame, height) do
    graph
    |> Scenic.Primitives.rect(
         {frame.dimensions.width, height}, [
            fill: :grey,
            translate: {
              frame.coordinates.x,
              frame.coordinates.y + frame.dimensions.height - height}])
  end


  # def handle_continue(:draw_frame, frame) do

  #   IO.inspect frame, label: "FFFFF"

  #   new_graph =
  #     frame.graph
  #     |> Draw.box(
  #             x: frame.coordinates.x,
  #             y: frame.coordinates.y,
  #         width: frame.width,
  #        height: frame.height)

  #   new_frame =
  #     %{frame|graph: new_graph}

  #   Logger.info("#{__MODULE__} initialization complete.")
  #   {:noreply, new_frame}
  #   # {:noreply, new_frame, push: new_graph}
  # end



  ## private functions
  ## -------------------------------------------------------------------


  # defp register_process() do
  #   #TODO search for if the process is already registered, if it is, engage recovery procedure
  #   Process.register(self(), __MODULE__) #TODO this should be gproc
  # end

  # def initialize(%Frame{} = frame) do
  #   # the textbox is internal to the command buffer, but we need the
  #   # coordinates of it in a few places, so we pre-calculate it here
  #   textbox_frame =
  #     %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

  #   Draw.blank_graph()
  #   |> Scenic.Primitives.group(fn graph ->
  #        graph
  #        |> Draw.background(frame, @command_mode_background_color)
  #        |> DrawingHelpers.draw_command_prompt(frame)
  #        |> DrawingHelpers.draw_input_textbox(textbox_frame)
  #        |> DrawingHelpers.draw_cursor(textbox_frame, id: @cursor_component_id)
  #        |> DrawingHelpers.draw_text_field("", textbox_frame, id: @text_field_id) #NOTE: Start with an empty string
  #   end, [
  #     id: @component_id,
  #     hidden: true
  #   ])
  # end


  # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c) do
  #   Graph.build()
  #   |> rect({w, h}, translate: {x, y}, fill: c)
  # end
  # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c, stroke: {s, border_color}) do
  #   Graph.build()
  #   |> rect({w, h}, translate: {x, y}, fill: c, stroke: {s, border_color})
  # end
end
