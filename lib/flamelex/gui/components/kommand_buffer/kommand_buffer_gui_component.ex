defmodule Flamelex.GUI.Component.KommandBuffer do
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.CommandBuffer.DrawingHelpers
  require Logger


  @component_id KommandBuffer   # Scenic required we register groups/components
                                # with a name - this is the name of this component


  def height, do: 32


  def rego_tag(_params) do
    {:gui_component, KommandBuffer}
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(params) do
    # res = Flamelex.Utils.PubSub.subscribe(topic: :gui_event_bus)
    params |> Map.merge(%{
      contents: ""
    })
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    default_kommand_buffer_graph(frame)
  end

  def handle_cast(:show, {graph, state}) do #TODO components have ordering reversed :(
    new_graph = graph |> set_visibility(:show)
    {:noreply, {new_graph, state}, push: new_graph}
  end

  def handle_cast(:hide, {graph, state}) do
    new_graph = graph |> set_visibility(:hide)
    {:noreply, {new_graph, state}, push: new_graph}
  end

  #TODO so, we should be able to just, subscribe to mode changes... dunno why it's not working
  def handle_info({:switch_mode, m}, state) do
    IO.puts "KOMMAND MSG - #{inspect m}"
    {:noreply, state}
  end

  # def handle_info({:switch_mode, _m}, state) do
  #   IO.puts "CONTROLLER SWITCHING MODE !!"
  #   {:noreply, state}
  # end


  # def draw_command_buffer(graph) do
  #   graph
  #   |> GUI.Component.CommandBuffer.add_to_graph(%{
  #     id: :command_buffer,
  #     # top_left_corner: {0, h - command_buffer.data.height},
  #     top_left_corner: {0, 400},
  #     # dimensions: {w, command_buffer.data.height},
  #     dimensions: {400, 20},
  #     mode: :echo,
  #     text: "Welcome to Franklin. Press <f1> for help."
  #   })
  # end




  def default_kommand_buffer_graph(%Frame{} = frame) do
    # the textbox is internal to the command buffer, but we need the
    # coordinates of it in a few places, so we pre-calculate it here
    textbox_frame =
      %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

    command_mode_background_color = :cornflower_blue
    # cursor_component_id           = {component_id, :cursor, 1}
    text_field_id                 = {@component_id, :text_field}

    Draw.blank_graph()
    |> Scenic.Primitives.group(fn graph ->
         graph
         |> Draw.background(frame, command_mode_background_color)
         |> DrawingHelpers.draw_command_prompt(frame)
         |> DrawingHelpers.draw_input_textbox(textbox_frame)
        #  |> DrawingHelpers.draw_cursor(textbox_frame, id: cursor_component_id)
         |> DrawingHelpers.draw_text_field("", textbox_frame, id: text_field_id) #NOTE: Start with an empty string
    end, [
      id: @component_id,
      hidden: true
    ])
  end


  def set_visibility(graph, reveal?) when reveal? in [:show, :hide] do
    hidden? = case reveal? do :show -> false
                              :hide -> true  end
    graph
    |> Scenic.Graph.modify(
         @component_id,
         &Scenic.Primitives.update_opts(&1, hidden: hidden?))
  end
end
