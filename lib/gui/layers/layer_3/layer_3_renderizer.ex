defmodule Flamelex.GUI.Layers.Layer3.Renderizer do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer3
  require Logger

  @layer_3 :layer_3

  # if the frame has changed, simply re-render everything from scratch
  # we could, potentially, pass this down instead, but honestly this is good enough for 99%
  # the weird edge cases might be processes which register with specific names might get conflicts
  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
    %Widgex.Frame{} = new_frame,
    %Layer3.State{} = state
  ) when old_frame != new_frame do
    # delete the old primitive to force a re-render from scratch
	IO.puts "RE RENDER 3"
    graph
    |> Scenic.Graph.delete(@layer_3)
    |> draw_layer_3(new_frame, state)
  end

  # in this case frame and state both match, there's no updates so don't do anything
  # note that using same variable names in both places means it must bind exactly i.e. they're equal
  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{assigns: %{
        frame: %Widgex.Frame{} = frame,
        state: %Layer3.State{} = state
      }} = scene,
    %Widgex.Frame{} = frame,
    %Layer3.State{} = state
  ) do
	IO.puts "DONT RENDER 3"
    Logger.debug "Layer3 render called, but no change detected."
    graph
  end

  def render(
    %Scenic.Graph{} = graph,  # this is the base graph, that we will update as it's passed through the render function
    %Scenic.Scene{} = scene,  # this is the current, scene, we can use this to compare old states/frames against new ones, also we need it to find the child-pids for components we started from this component
    %Widgex.Frame{} = frame,  # this is the new Widgex frame, if this isn't supposed to change just pass back in the old one
    %Layer3.State{} = state   # this is the new Layer state, again if this isn't changing just pass the old one in and our comparison/update algorithm won't make any changes
  ) do
    # if the layer isn't in the base graph, we need to draw it,
    # otherwise proceed to render pipeline
    IO.puts "IN FOR A PENNY"
    case Scenic.Graph.get(graph, @layer_3) do
      [] ->
        graph
        |> draw_layer_3(frame, state)

      _primitive ->
        graph
        |> render_popup_modal(frame, state)
        |> render_overlays(frame, state)
    end
  end

  # this function literally always adds a new layer to the graph,
  # so we need to only call it when this component got deleted/hasn't been drawn yet
  defp draw_layer_3(graph, frame, state) do
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      |> render_popup_modal(frame, state)
      |> render_overlays(frame, state)
    end, id: @layer_3)
  end

  @popup_modal :popup_modal

  defp render_popup_modal(graph, frame, %{open_memex_popup_open?: true} = state) do
    case Scenic.Graph.get(graph, @popup_modal) do
      [] ->
        # draw the modal
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> render_background(frame, state)
          |> render_modal_box(frame, state)
        end, id: @popup_modal)

      _primitive ->
        # push the modal through the render/update pipeline
        graph
        |> render_background(frame, state)
        |> render_modal_box(frame, state)
    end
  end

  defp render_popup_modal(graph, frame, %{start_new_memex_popup_open?: true} = state) do
	IO.puts "YYYYY OPEN TrUE FOR START"
    case Scenic.Graph.get(graph, @popup_modal) do
      [] ->
        # draw the modal
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> render_background(frame, state)
          |> render_modal_box(frame, state)
        end, id: @popup_modal)

      _primitive ->
        # push the modal through the render/update pipeline
        graph
        |> render_background(frame, state)
        |> render_modal_box(frame, state)
    end
  end

  defp render_popup_modal(graph, _frame, _state) do
    case Scenic.Graph.get(graph, @popup_modal) do
      [] ->
        # we aren't supposed to show the popup, and it isn't there, so just do nothing
        graph

      _primitive ->
        # hide the modal by straight up deleting it !
        graph
        |> Scenic.Graph.delete(@popup_modal)
    end
  end

  # @modal_box :modal_box
  # defp render_modal_box(graph, frame, state) do
  #   case Scenic.Graph.get(graph, @modal_box) do
  #     [] ->
  #       graph
  #       |> draw_modal_box(frame, state)

  #     _primitive ->
  #       # The modal box already exists; no need to redraw
  #       graph
  #   end
  # end

  @overlays :overlays
  defp render_overlays(graph, frame, %{show_window_mode_overlay?: true} = state) do
    case Scenic.Graph.get(graph, @overlays) do
      [] ->
        right_pad = 2
        menu_bar_height = 58

        f = Widgex.Frame.new(%{pin: {frame.size.width-200-right_pad, frame.size.height+menu_bar_height-50}, size: {200, 50}})

        graph
        |> Scenic.Primitives.rect(f.size.box,
                # id: @background,
                # fill: {:color_rgba, @semi_transparent_black},
                translate: f.pin.point,
                stroke: {2, :blue}
            )
        |> ScenicWidgets.Markup.Header6.draw(f, "WINDOW OVRLAY")

      _primitive ->
        # leave it
        graph
    end
  end

  defp render_overlays(graph, frame, %{show_window_mode_overlay?: false} = state) do
    case Scenic.Graph.get(graph, @overlays) do
      [] ->
        # do nothing don't show it
        graph

      _primitive ->
        # If it exists then take it off
        graph
        |> Scenic.Graph.delete(@overlays)
    end
  end

  @background :background
  @semi_transparent_white {255, 255, 255, 85}
  @semi_transparent_black {0, 0, 0, 167}

  defp render_background(graph, frame, _state) do
    case Scenic.Graph.get(graph, @background) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
            id: @background,
            fill: {:color_rgba, @semi_transparent_black},
            translate: frame.pin.point
        )

      _primitive ->
        # TODO right now we cant change the color of the background but eventually, we will
        graph
        # |> Scenic.Graph.modify(@background,
        #   &Scenic.Primitives.update_opts(&1, fill: new_state.colors.slate)
        # )
    end
  end

  @modal_box :modal_box
  defp render_modal_box(graph, frame, state) do
    case Scenic.Graph.get(graph, @modal_box) do
      [] ->
        graph
        |> draw_modal_box(frame, state)

      _primitive ->
        # The modal box already exists; no need to redraw
        graph
    end
  end

  defp draw_modal_box(graph, frame, state) do
    modal_width = frame.size.width * 0.6
    modal_height = frame.size.height * 0.67
    modal_x = frame.pin.x + (frame.size.width - modal_width) / 2
    modal_y = frame.pin.y + (frame.size.height - modal_height) / 2
    corner_radius = 14
    button_size = 48
    button_padding = 10
    button_rect_size = 36
    button_corner_radius = 12

    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      |> Scenic.Primitives.rrect({modal_width, modal_height, corner_radius},
        fill: :white,
        stroke: {2, :blue},
        translate: {modal_x, modal_y}
      )
      |> draw_modal_box_content(frame, state)
      |> draw_close_modal_button(frame, state)
    end, id: @modal_box)
  end

  defp draw_modal_box_content(graph, frame, state) do
    font_size = 24

    modal_width = frame.size.width * 0.6
    modal_height = frame.size.height * 0.67
    modal_x = frame.pin.x + (frame.size.width - modal_width) / 2
    modal_y = frame.pin.y + (frame.size.height - modal_height) / 2

    ## todo should look at state but for now only support now
    graph
    |> Scenic.Primitives.text("Check terminal plz",
      id: :modal_content,
      font: :ibm_plex_mono,
      font_size: font_size,
      fill: :black,
      translate: {modal_x + 50, modal_y + 50}
    )
  end

  defp draw_close_modal_button(graph, frame, state) do
    modal_width = frame.size.width * 0.6
    modal_height = frame.size.height * 0.67
    modal_x = frame.pin.x + (frame.size.width - modal_width) / 2
    modal_y = frame.pin.y + (frame.size.height - modal_height) / 2
    corner_radius = 14
    font_size = 48
    button_padding = 10
    button_rect_size = 52
    button_corner_radius = 12

    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      # Rounded rectangle background
      |> Scenic.Primitives.rrect({button_rect_size, button_rect_size, button_corner_radius},
        id: :close_modal_btn,
      # |> Scenic.Primitives.rect({button_rect_size, button_rect_size},
        fill: :light_gray,
        stroke: {2, :dark_gray},
        translate: {
          modal_x + modal_width - button_rect_size - button_padding,
          modal_y + button_padding
        },
        input: :cursor_button
      )
      # "X" text centered within the rectangle
      |> Scenic.Primitives.text("X",
        id: :cancel_button,
        font: :ibm_plex_mono,
        font_size: font_size,
        translate: {
          modal_x + modal_width - button_rect_size - button_padding + ((button_rect_size-x_width(font_size))/2),
          # TODO calculate this nicely, no magic numbers!
          modal_y + font_size + 5
        },
        fill: :red
      )
    end, id: :close_modal_button)
  end

  defp x_width(font_size) do
    {:ok, font_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    FontMetrics.width("X", font_size, font_metrics)
  end

end
