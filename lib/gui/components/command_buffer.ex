defmodule GUI.Components.CommandBuffer do
  use Scenic.Component
  alias Scenic.Graph
  require Logger
  import Scenic.Primitives

  @text_size 24 #32 px
  @text_size_px 32

  @prompt_margin 12
  @prompt_size 24
  @prompt_to_blinker_distance 32

  @empty_command_buffer_text_prompt "Enter a command..."

  @impl Scenic.Component
  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h},
    state: %{text: _t}} = data) do
      {:ok, data}
    end
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  @impl Scenic.Component
  def init(%{state: %{text: _t}} = data, opts), do: init_logic(data, opts)

  # def show, do: show_command_buffer()


  ## Private functions
  ## -------------------------------------------------------------------


  defp init_logic(%{state: %{text: initial_text}} = data, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    # GenServer.call(GUI.Scene.Root, {:register, :command_buffer})

    state = %{
      component_ref: [],
      text: "",
      data: data
    }

    %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}} = data

    # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
    y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
    text_centering_offset = (@text_size_px - @text_size)/2

    # text draws from bottom-left corner?? :(
    lower_left_corner_x = @prompt_margin - 1
    lower_left_corner_y = y_offset + @text_size - text_centering_offset - 1

    graph =
      Graph.build(font_size: @text_size, font: opts[:styles][:font])
      |> text(initial_text,
          translate: {lower_left_corner_x, lower_left_corner_y},
          fill: :dark_grey)
      # |> draw_status_bar(data)
      # |> group(fn graph ->
      #      graph
      #      |> draw_background(data)
      #      |> draw_command_prompt(data)
      #      |> add_blinking_box_cursor(data)
      #      |> draw_command_prompt_text(state, data)
      #    end, [
      #      id: data.id,
      #      hidden: true
      #    ])

    {:ok, {state, graph}, push: graph}
  end

  defp draw_status_bar(graph, data) do
    graph
    |> group(fn graph ->
         graph
         |> draw_background(data, :white_smoke)
         |> print_mode(data)
       end, [
         id: data.id
       ])
  end

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})

  def handle_cast({:action, 'SHOW_EXECUTE_COMMAND_PROMPT'}, {state, _graph}) do
    new_graph =
      Scenic.Graph.build()
        |> group(fn graph ->
          graph
          |> draw_background(state.data)
          |> draw_command_prompt(state.data)
          |> add_blinking_box_cursor(state.data)
          |> draw_command_prompt_text(state, state.data)
        end, [
          id: :command_buffer,
        #  hidden: true
        ])

    {:noreply, {state, new_graph}, push: new_graph}
  end

  def handle_cast({:action, action}, {state, graph}) do
    case GUI.Components.CommandBuffer.Reducer.process({state, graph}, action) do
      {new_state, %Scenic.Graph{} = new_graph} when is_map(new_state)
        -> {:noreply, {new_state, new_graph}, push: new_graph}
      new_state when is_map(new_state)
        -> {:noreply, {new_state, graph}}
    end
  end

  def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
    Process.monitor(pid)

    new_component = {identifier, pid}
    new_ref_list = ref_list ++ [new_component]
    new_state = state |> Map.replace!(:component_ref, new_ref_list)

    {:reply, :ok, {new_state, graph}}
  end

  def handle_info({:DOWN, ref, :process, object, reason}, _state) do
    context = %{ref: ref, object: object, reason: reason}
    raise "Monitored process died. #{inspect context}"
  end


  ## Private functions
  ## -------------------------------------------------------------------


  defp draw_background(graph, d = %{top_left_corner: {top_left_x, top_left_y}, dimensions: {width, height}}, color) when is_atom(color) do
    IO.inspect d
    graph
    |> rect({width + 1, height}, [ #TODO need +1 here for some reason
         fill: color,
         translate: {top_left_x, top_left_y}
       ])
  end
  defp draw_background(graph, %{top_left_corner: {top_left_x, top_left_y}, dimensions: {width, height}}) do
    graph
    |> rect({width, height}, [
         fill: :purple,
         translate: {top_left_x, top_left_y}
       ])
  end

  defp print_mode(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
    # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
    y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
    text_centering_offset = (@text_size_px - @text_size)/2

    # text draws from bottom-left corner?? :(
    lower_left_corner_x = @prompt_margin
    lower_left_corner_y = y_offset + @text_size - text_centering_offset

    graph
    |> text("COMMAND",
         translate: {lower_left_corner_x, lower_left_corner_y},
         fill: :midnight_blue)
    |> text("MODE",
         translate: {lower_left_corner_x+18, lower_left_corner_y + 18},
         fill: :midnight_blue)
  end

  defp draw_command_prompt(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
    x_margin = @prompt_margin
    y_offset = top_left_y + (height - @prompt_size)/2 # from the top-left position of the box, the command prompt y-offset. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer

    # cmd_prompt_coordinates =
    #   x - point 1
    #   |\
    #   | \ x - point 2 (apex of triangle)
    #   | /
    #   |/
    #   x - point

    cmd_prompt_coordinates =
      {{x_margin, y_offset}, # point 1

            {x_margin+@prompt_size*0.67, y_offset+@prompt_size/2}, # point 2

      {x_margin, y_offset + @prompt_size}} # point 3

    graph
    |> triangle(cmd_prompt_coordinates, fill: :ghost_white)
  end

  defp add_blinking_box_cursor(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do

    {_x_min, _y_min, _x_max, y_max} =
      GUI.FontHelpers.get_max_box_for_ibm_plex(@text_size)

    y_offset     = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
    y_box_buffer = 2 # it looks weird having box exact same size as the text
    x_coordinate = @prompt_margin + @prompt_to_blinker_distance
    y_coordinate = y_offset + y_box_buffer
    width        = GUI.FontHelpers.monospace_font_width(:ibm_plex, @text_size)  #TODO should probably truncate this
    height       = y_max + y_box_buffer #TODO should probably truncate this

    graph
    |> GUI.Component.Cursor.add_to_graph(%{
         top_left_corner: {x_coordinate, y_coordinate},
         dimensions: {width, height},
         parent: %{pid: self()},
         id: :cursor
       })
  end

  defp draw_command_prompt_text(graph, %{text: text}, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
    # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
    y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
    text_centering_offset = (@text_size_px - @text_size)/2

    # text draws from bottom-left corner?? :(
    lower_left_corner_x = @prompt_margin + @prompt_to_blinker_distance
    lower_left_corner_y = y_offset + @text_size - text_centering_offset

    text = if text == "", do: @empty_command_buffer_text_prompt, else: text

    graph
    |> text(text,
         id: :buffer_text,
         translate: {lower_left_corner_x, lower_left_corner_y},
         fill: :dark_grey)
  end
end
