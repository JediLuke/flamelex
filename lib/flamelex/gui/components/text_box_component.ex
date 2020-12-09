defmodule Flamelex.GUI.Component.TextBox do
  @moduledoc """
  This module is just an example. Copy & modify it.
  """
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.Utils.TextBox, as: TextBoxDrawUtils


  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(_frame, _params) do
    cursor_position = %{row: 0, col: 0}

    GenServer.cast(self(), :start_blink)
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def render(%Frame{} = frame, _params) do

    #TODO make the frame, only 72 columns wide !!

    lines_of_text =
        Flamelex.API.Buffer.read(frame.id) #TODO this is bad... Frame shouldn't be the key we're passing around here
        |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()

    background_color =
      Flamelex.GUI.Colors.background()
      # :green

    Draw.blank_graph()
    |> Draw.background(frame, background_color)
    |> TextBoxDrawUtils.render_lines(%{ lines_of_text: lines_of_text,
                                        top_left_corner: frame.coordinates })
    |> Draw.border(frame)
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
