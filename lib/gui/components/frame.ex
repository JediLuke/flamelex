defmodule Flamelex.GUI.Component.Frame do
  @moduledoc """
  Frames are a very special type of Component - they are a container,
  manipulatable by the layout of the root scene. Virtually all buffers
  will render their corresponding Component in a Frame.
  """

  use Scenic.Component
  use Flamelex.ProjectAliases
  require Logger


  @impl Scenic.Component
  def verify(%Frame{} = frame), do: {:ok, frame}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def init(%Frame{} = frame, _opts) do
    # IO.puts "Initializing #{__MODULE__}..."
    {:ok, frame, push: GUI.GraphConstructors.Frame.convert(frame)}
  end

  # left-click
  def handle_input({:cursor_button, {:left, :press, _dunno, _coords}} = action, _context, frame) do
    # new_frame = frame |> ActionReducer.process(action)
    new_graph = frame |> GUI.GraphConstructors.Frame.convert_2()
    {:noreply, frame, push: new_graph}
  end

  def handle_input(event, _context, state) do
    # state = Map.put(state, :contained, true)
    IO.puts "EVENT #{inspect event}"
    # {:noreply, state, push: update_color(state)}
    {:noreply, state}
  end

  # def filter_event(event, _, state) do
  #   IO.puts "EVENT #{event}"
  #   {:cont, {:click, :transformed}, state}
  # end

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
