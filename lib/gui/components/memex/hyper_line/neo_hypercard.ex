defmodule Flamelex.GUI.Components.NeoHyperCard do
  use Scenic.Component
  require Logger

  def validate(%{frame: %Widgex.Frame{} = _f, tidbit: %Memelex.TidBit{} = _t} = data) do
    {:ok, data}
  end

  def init(scene, args, opts) do
    init_graph = render(Scenic.Graph.build(), args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      |> assign(tidbit: args.tidbit)
      |> push_graph(init_graph)

    # Don't request global cursor_button input - let events bubble up naturally
    # request_input(init_scene, [:cursor_button])

    {:ok, init_scene}
  end

  def render(graph, %{frame: frame, tidbit: %Memelex.TidBit{} = t}) do
    render(graph, %{frame: frame, tidbit: t, selected?: false})
  end
  
  def render(graph, %{frame: frame, tidbit: %Memelex.TidBit{} = t, selected?: selected?}) do
    # need to anchor the new frame within this one, not re-use the same pin
    header_frame = Widgex.Frame.new(%{pin: {0, 0}, size: frame.size.box})

    fill_color = calc_fill_color(t)
    stroke_style = if selected?, do: {4, :yellow}, else: {2, :blue}
    
    # Extract priority and status from meta for TODOs
    {priority, status} = case t.meta do
      [%{"priority" => p, "status" => s} | _] -> {p, s}
      [%{"priority" => p} | _] -> {p, nil}
      [%{"status" => s} | _] -> {nil, s}
      _ -> {nil, nil}
    end

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.rect(frame.size.box, fill: fill_color, stroke: stroke_style)
        |> render_todo_content(header_frame, frame, t, priority, status)
      end,
      translate: frame.pin.point,
      # Add semantic marker for testing
      id: {:todo_item, t.uuid},
      # Enable input events for this group
      input: [:cursor_button]
    )
  end
  
  defp render_todo_content(graph, header_frame, frame, t, priority, status) do
    graph
    # Title
    |> ScenicWidgets.Markup.Header6.draw(header_frame, t.title)
    # Priority badge
    |> render_priority_badge(priority, {frame.size.width - 70, 5})
    # Status indicator
    |> render_status_text(status, {5, 25})
  end
  
  defp render_priority_badge(graph, nil, _pos), do: graph
  defp render_priority_badge(graph, priority, {x, y}) do
    badge_color = case priority do
      "high" -> :red
      "medium" -> :orange  
      "low" -> :green
      _ -> :grey
    end
    
    graph
    |> Scenic.Primitives.rect({60, 20}, 
      fill: badge_color, 
      stroke: {1, :black},
      translate: {x, y})
    |> Scenic.Primitives.text(String.upcase(priority),
      font_size: 12,
      font: :ibm_plex_mono,
      fill: :white,
      text_align: :center,
      translate: {x + 30, y + 14})
  end
  
  defp render_status_text(graph, nil, _pos), do: graph
  defp render_status_text(graph, status, {x, y}) do
    text_color = case status do
      "done" -> :dark_green
      "in_progress" -> :dark_blue
      "pending" -> :dark_grey
      _ -> :black
    end
    
    graph
    |> Scenic.Primitives.text("Status: #{status}",
      font_size: 10,
      font: :ibm_plex_mono,
      fill: text_color,
      translate: {x, y})
  end

  def handle_input({:cursor_button, {:btn_left, 0, [], click_coords}}, _context, scene) do
    bounds = Scenic.Graph.bounds(scene.assigns.graph)

    if click_coords |> ScenicWidgets.Utils.inside?(bounds) do
      # IO.puts("CLICKCLIKC #{scene.assigns.tidbit.title}")
      cast_parent(scene, {:click, scene.assigns.tidbit})
    end

    {:noreply, scene}
  end

  def handle_input({:cursor_button, _otherwise}, _context, scene) do
    # Logger.debug "#{__MODULE__} ignoring input: #{inspect input}..."
    {:noreply, scene}
  end

  def calc_fill_color(%Memelex.TidBit{} = t) do
    # Extract status from meta field for TODOs
    status = case t.meta do
      [%{"status" => s} | _] -> s
      _ -> t.status  # fallback to direct status field for non-TODOs
    end
    
    cond do
      status in [:done, "done"] -> :green
      Memelex.My.TODOs.action_date_passed?(t) -> :red
      status in [:in_progress, "in_progress"] -> :yellow
      true -> :grey
    end
  end

  # next 2 todos for todo list

  # - handle "new tidbit savbed" event and auto-refresh
  # - allow scrolling within the vertical list
  # - add priority/sorting within the list and make them clickable
end
