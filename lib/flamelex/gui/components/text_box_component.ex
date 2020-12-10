defmodule Flamelex.GUI.Component.TextBox do
  @moduledoc """
  This module is just an example. Copy & modify it.
  """
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.Utils.TextBox, as: TextBoxDrawUtils
  alias Flamelex.GUI.Component.MenuBar


  @blink_ms trunc(500) # blink speed in hertz


  @impl Flamelex.GUI.ComponentBehaviour
  #TODO this is a deprecated version of render
  def render(%Frame{} = frame, params) do
    render(params |> Map.merge(%{frame: frame}))
  end

  def render(%{frame: %Frame{} = frame} = params) do

    #TODO make the frame, only 72 columns wide !!
    frame =
      if we_are_drawing_a_footer_bar?(params) do
        frame |> Frame.resize(reduce_height_by: MenuBar.height()+1) #TODO why do we need +1 here??
      else
        frame # no need to make any adjustments
      end

    lines_of_text =
      Flamelex.API.Buffer.read(frame.id) #TODO this is bad... Frame shouldn't be the key we're passing around here
      |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()

    background_color = Flamelex.GUI.Colors.background()

    Draw.blank_graph()
    |> Draw.background(frame, background_color)
    |> TextBoxDrawUtils.render_lines(%{ lines_of_text: lines_of_text,
                                        top_left_corner: frame.coordinates })
    |> Draw.border(frame)
  end

  defp we_are_drawing_a_footer_bar?(%{draw_footer?: df?}), do: df?
  defp we_are_drawing_a_footer_bar?(_else), do: false

  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(params) do
    #TODO spin up new cursor component!!
    GenServer.cast(self(), :start_blink)

    params |> Map.merge(%{
      timer: nil,
      draw_footer?: true,
      cursor_position: %{line: 0, col: 0}
    })
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_graph, _state}, action) do
    Logger.info "#{__MODULE__} received an action - #{inspect action}"
    :ignore_action
  end


  @doc """
  This callback is called whenever the component received input.
  """
  @impl Scenic.Scene
  def handle_input(event, _context, state) do
    Logger.debug "#{__MODULE__} received event: #{inspect event}"
    {:noreply, state}
  end


  def handle_cast(:start_blink, {graph, state}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {graph, new_state}}
  end

  def handle_info(:blink, state) do

    # new_blink = not state.cursor_blink?

    # new_graph =
    #   Draw.blank_graph()
    #   |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
    #   |> TextBoxDraw.render_text_grid(%{
    #        frame: state.frame,
    #        text: state.text,
    #        cursor_position: state.cursor_position,
    #        cursor_blink?: new_blink,
    #        mode: state.mode
    #      })
    #   |> Frame.draw(state.frame, %{mode: state.mode})

    # new_state =
    #   %{state|graph: new_graph, cursor_blink?: new_blink}

    # {:noreply, new_state, push: new_graph}

    IO.puts "BLINKY!"
    {:noreply, state}
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
end
