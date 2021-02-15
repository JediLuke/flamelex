defmodule Flamelex.GUI.Component.TextBox do
  @moduledoc """
  This module is just an example. Copy & modify it.
  """
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.Utils.TextBox, as: TextBoxDrawUtils
  alias Flamelex.GUI.Component.MenuBar
  alias Flamelex.GUI.Component.TextCursor




  # def tag(%{}) do
  #   {:gui_component, }
  # end

  def rego_tag(%{ref: buffer}) do
    {:gui_component, buffer}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(%{frame: %Frame{} = f} = params) do

    #TODO can probs get this direct from buf state?
    lines_of_text =
      # Flamelex.API.Buffer.read(buf)
      params.data
      |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()

    #TODO this is the whole textbox
    params |> Map.merge(%{
      draw_footer?: true,
      cursors: [
        %{ frame: f, ref: rego_tag(params), num: 1 } #TODO use cursor struct, add frame to cursor struct
      ],
      num_lines: lines_of_text |> length()
    })
  end

  @impl Flamelex.GUI.ComponentBehaviour
  #TODO this is a deprecated version of render
  def render(%Frame{} = frame, params) do
    render(params |> Map.merge(%{frame: frame}))
  end

  def render(%{ref: buf, frame: %Frame{} = frame} = params) do

    #TODO make the frame, only 72 columns wide !!
    frame =
      if we_are_drawing_a_footer_bar?(params) do
        frame |> Frame.resize(reduce_height_by: MenuBar.height()+1) #TODO why do we need +1 here??
      else
        frame # no need to make any adjustments
      end

    #TODO get margins from somewhere better
    frame = frame |> Frame.set_margin(%{top: 24, left: 8})

    lines_of_text =
      Flamelex.API.Buffer.read(buf)
      |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()

    background_color = Flamelex.GUI.Colors.background()

    Draw.blank_graph()
    |> Draw.background(frame, background_color)
    |> TextBoxDrawUtils.render_lines(%{ lines_of_text: lines_of_text,
                                        frame: frame })
    |> draw_cursors(frame, params)
    |> Draw.border(frame)
  end

  def draw_cursors(graph, _frame, %{cursors: []}), do: graph
  def draw_cursors(graph, frame, %{cursors: cursors})
    when is_list(cursors) and length(cursors) >= 1
  do
    Enum.reduce(cursors, _init_acc={graph, _first_cursor_num=1}, fn c, {graph, n} ->
      graph |> TextCursor.mount(c |> Map.merge(%{frame: frame, num: n}))
    end)
  end


  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_action({_graph, state}, {:move_cursor, _direction, _distance} = cursor_movement_action) do

  #   %{ref: %BufRef{ref: buf_ref}} = state

  #   #assume its cursor 1 for now
  #   cursor_tag = {:gui_component, {:text_cursor, buf_ref, 1}} #TODO assume its cursor 1

  #   ProcessRegistry.find!(cursor_tag)
  #   |> GenServer.cast({:action, cursor_movement_action})

  #   :ignore_action
  # end

  def handle_cast({:move_cursor, %{last: :line, same: :column}} , {graph, state}) do



  end

  def handle_cast({:move_cursor, details}, {graph, state}) do

    # instructions = translate_details(state, details)

    {:gui_component, {:text_cursor, state.ref.ref, 1}} #TODO standardize this bastard wannabee tree format, also lmao
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move, details})

    {:noreply, {graph, state}}
  end

  # defp translate_details(state, %{instructions: %{last: :line, same: :column}} = details) do
  #   IO.puts "I know you pressed G..."

  #   lines_of_text =
  #     Flamelex.API.Buffer.read(state.ref)
  #     |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()


  #   num_lines = lines_of_text |> Kernel.length()

  #   details
  #   |> Map.put(:instructions, {:down, num_lines, :line})
  # end

  # defp translate_details(_state, details) do
  #   details
  # end



  # def handle_action({_g, _s}, {:move_cursor, details}) do
  #   IO.inspect details, label: "HERE IS WHERE THE ACTION IS"
  #   :ignore_action
  # end

  def handle_info({:switch_mode, m}, state) do
    GenServer.cast(self(), {:action, {:switch_mode, m}})
    # {:noreply, state |> switch_mode(m)}
    {:noreply, state}
  end

  # def switch_mode(state, m) do

  # end

  def handle_info(msg, state) do
    IO.puts "#{__MODULE__} got info msg: #{inspect msg}, state: #{inspect state}"
    {:noreply, state}
  end


  def handle_action({graph, state}, {:switch_mode, new_mode}) do


    %{ref: %{ref: buf_ref}} = state

    #assume its cursor 1 for now
    cursor_tag = {:gui_component, {:text_cursor, buf_ref, 1}} #TODO assume its cursor 1

    ProcessRegistry.find!(cursor_tag)
    |> GenServer.cast({:action, {:switch_mode, new_mode}})

    mode_string =
      case new_mode do
        :normal -> "NORMAL-MODE"
        :insert -> "INSERT-MODE"
        :command -> "COMMAND-MODE"
      end

    new_graph =
      graph
      |> Scenic.Graph.modify(:mode_string, &Scenic.Primitives.text(&1, mode_string))
      #TODO also we want to change the color of the box!
      # |> Frame.redraw()

    {:noreply, {new_graph, state}, push: new_graph}
  end

  @doc """
  This callback is called whenever the component received input.
  """
  @impl Scenic.Scene
  def handle_input(event, _context, state) do
    {:noreply, state}
  end



  def handle_cast({:refresh, _buf_state, _gui_state}, {_graph, state}) do

    new_graph = render(state)

    {:noreply, {new_graph, state}, push: new_graph}

        # data  = Buffer.read(buf)
    # frame = calculate_framing(filename, state.layout)

    # new_graph =
    #   state.graph
    #   # |> Scenic.Graph.modify(@text_field_id, fn x ->
    #   #   IO.puts "YES #{inspect x}"
    #   #   x
    #   # end)
    #   # |> Flamelex.GUI.Component.TextBox.draw({frame, data, %{}}) #TODO check the old process is dieing...
    #   |> Flamelex.GUI.Component.TextBox.mount(%{frame: frame})
    #   |> Draw.test_pattern()

    # Flamelex.GUI.RootScene.redraw(new_graph)

    # {:noreply, %{state|graph: new_graph}}

  end


  @doc """
  When placed at the bottom of the module, this function would serve as
  a "catch-all", by pattern-matching on all actions that weren't matched
  in a `handle_action/2` callback defined above.
  """
  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_action({graph, _state}, action) do
  #   Logger.debug "#{__MODULE__} with id: #{inspect state.id} received unrecognised action: #{inspect action}"
  #   :ignore_action
  # end


  defp we_are_drawing_a_footer_bar?(%{draw_footer?: df?}), do: df?
  defp we_are_drawing_a_footer_bar?(_else), do: false
end











# defmodule Flamelex.GUI.Component.DeprecatedTextBox do
#   @moduledoc false
#   use Scenic.Component
#   require Logger
#   use Flamelex.ProjectAliases



#   # def handle_cast({:refresh, buf}, state) do
#   #   state = %{state|text: buf.data}
#   #   new_graph = render_graph(state)
#   #   new_state = %{state| graph: new_graph}
#   #   {:noreply, new_state, push: new_graph}
#   # end

#   def handle_cast({:move_cursor, direction, _dist}, state) do

#     _old_cursr_position = %{row: rr, col: cc} = state.cursor_position
#     new_cursor_position =
#       case direction do
#         :left  -> %{row: rr,   col: cc-1}
#         :down  -> %{row: rr-1, col: cc}
#         :up    -> %{row: rr+1, col: cc}
#         :right -> %{row: rr,   col: cc+1}
#       end

#     new_graph =
#       Draw.blank_graph()
#       |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
#       |> TextBoxDraw.render_text_grid(%{
#            frame: state.frame,
#            text: state.text,
#            cursor_position: new_cursor_position,
#            cursor_blink?: state.cursor_blink?
#          })
#       |> Frame.draw(state.frame, %{mode: :normal})

#     new_state = %{state| graph: new_graph,
#                          cursor_position: new_cursor_position }

#     {:noreply, new_state, push: new_graph}
#   end

#   def handle_cast({:move_cursor, new_cursor_position}, state) do

#     new_graph =
#       Draw.blank_graph()
#       |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
#       |> TextBoxDraw.render_text_grid(%{
#            frame: state.frame,
#            text: state.text,
#            cursor_position: new_cursor_position,
#            cursor_blink?: state.cursor_blink?
#          })
#       |> Frame.draw(state.frame, %{mode: state.mode})

#     new_state = %{state| graph: new_graph,
#                          cursor_position: new_cursor_position }

#     {:noreply, new_state, push: new_graph}
#   end

#   def handle_cast({:switch_mode, m}, state) do
#     new_graph =
#       Draw.blank_graph()
#       |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
#       |> TextBoxDraw.render_text_grid(%{
#            frame: state.frame,
#            text: state.text,
#            cursor_position: state.cursor_position,
#            cursor_blink?: state.cursor_blink?,
#            mode: m
#          })
#       |> Frame.draw(state.frame, %{mode: m})

#     new_state = %{state| graph: new_graph, mode: m}

#     {:noreply, new_state, push: new_graph}
#   end


#   # defp add_notes(graph, contents) do
#   #   {graph, _offset_count} =
#   #     Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
#   #       graph =
#   #         graph
#   #         |> Scenic.Primitives.group(fn graph ->
#   #               graph
#   #               |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
#   #               |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
#   #                   translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#   #                   font_size: 24, fill: :black)
#   #             end)


#   #       {graph, offset_count + 1}
#   #     end)

#   #   graph
#   # end


# end
