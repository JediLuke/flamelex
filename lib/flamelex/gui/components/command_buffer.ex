defmodule Flamelex.GUI.Component.CommandBuffer do
  use Scenic.Component
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Component.CommandBuffer.DrawingHelpers
  require Logger
  @moduledoc """
  This module is responsible for drawing the CommandBuffer.
  """
  import Scenic.Primitives


  def height, do: 32

  # @impl Scenic.Component
  # def verify(%Frame{} = data), do: {:ok, data}
  # def verify(_else), do: :invalid_data

  # @impl Scenic.Component
  # def info(_data), do: ~s(Invalid data)
  @impl Scenic.Component
  def verify({%Frame{} = frame, params}) when is_map(params), do: {:ok, {%Frame{} = frame, params}}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  @component_id :command_buffer
  @text_field_id {@component_id, :text_field}

  ## Public API
  ## -------------------------------------------------------------------

  #TODO this is just straight from ComponentBehaviour
  # def mount(%Scenic.Graph{} = graph, %Frame{} = frame, params \\ %{}) do
  def mount(%Scenic.Graph{} = graph, %{frame: %Frame{} = frame} = params) do
    graph |> add_to_graph({frame, params}, id: @component_id) #REMINDER: This will pass `frame` to this modules init/2
  end

  def show do
    IO.puts "COMPONENT SHOW???"
    #TODO this should be checking if the process exists (& will be, when we wrap it all up into component behaviour)
    GenServer.cast(__MODULE__, :show)
  end

  def hide do
    #TODO this should be checking if the process exists (& will be, when we wrap it all up into component behaviour)
    GenServer.cast(__MODULE__, :hide)
  end

  def cast(x) do
    GenServer.cast(__MODULE__, x)
  end

  def update(x) do
    GenServer.cast(__MODULE__, {:update, x})
  end


  @impl Scenic.Scene
  def init({%Frame{} = state, _params}, _opts) do
    # IO.puts "Initializing #{__MODULE__}..."

    #TODO search for if the process is already registered, if it is, engage recovery procedure
    ProcessRegistry.register({:gui_component, :command_buffer})

    graph = initialize(state)

    {:ok, {state, graph}, push: graph}
  end

  def handle_cast({:redraw, new_graph}, {state, _graph}) do
    {:noreply, {state, new_graph}, push: new_graph}
  end

  # {:key, {"K", :release, 0}}
  def handle_cast({:input, {:key, {_letter, :release, _num?}}}, state) do
    {:noreply, state} # ignore key releases
  end

  def handle_cast({:update, {:text, new_text}}, {state, graph}) do

    new_graph =
      graph
      |> Scenic.Graph.modify(@text_field_id, &text(&1, new_text))
      # |> Scenic.Graph.modify(@text_field_id, fn x ->

      #   IO.puts "YES #{inspect x}"
      #   x
      # end)

    {:noreply, {state, new_graph}, push: new_graph}
  end

  # {:key, {"K", :release, 0}}
  # def handle_cast({:input, {:key, {letter, something, num}}}, {state, graph}) do
  #   # new_data = state.data <>
  #   IO.inspect something
  #   IO.inspect num

  #   new_text = "Drugs!!~~~~~" <> letter

  #   new_graph =
  #     graph |> Scenic.Graph.modify(@text_field_id, &text(&1, new_text))

  #   {:noreply, {state, new_graph}, push: new_graph}
  # end

  # def handle_cast({:input, {:codepoint, {letter, num}}}) do
  #   new_text = "Drugs!!~~~~~" <> letter
  # end

  # def handle_cast({:input, {:viewport_exit, _coords}}, state) do
  #   {:noreply, state} # ignore
  # end


  # def draw(%Scenic.Graph{} = graph, viewport: %Dimensions{} = vp) do
  #   command_buffer =
  #     Frame.new(
  #       id: :command_buffer_frame,
  #       top_left_corner: Coordinates.new(
  #               x: 0,
  #               y: vp.height - @command_buffer_height),
  #       dimensions: Dimensions.new(
  #               width:  vp.width + 1, #TODO why do we need that +1?? Without it, you can definitely see a thin black line on the edge
  #               height: @command_buffer_height))

  #   graph
  #   |> add_to_graph(command_buffer)
  # end

  def handle_cast(:show, {state, graph}) do
    IO.puts "SHOWING!!!"
    new_graph = graph |> set_visibility(@component_id, :show)
    {:noreply, {state, new_graph}, push: new_graph}
  end

  def handle_cast(:hide, {state, graph}) do
    new_graph = graph |> set_visibility(@component_id, :hide)
    {:noreply, {state, new_graph}, push: new_graph}
  end

  def set_visibility(graph, component_id, :show) do
    graph |> set_visibility(component_id, _hidden? = false)
  end
  def set_visibility(graph, component_id, :hide) do
    graph |> set_visibility(component_id, _hidden? = true)
  end
  def set_visibility(graph, component_id, hidden?) when is_boolean(hidden?) do
    graph |> Scenic.Graph.modify(
                            component_id,
                            &update_opts(&1, hidden: hidden?))
  end


  # def action(a) do
  #   GenServer.cast(__MODULE__, {:action, a})
  # end

  # def redraw(%Scenic.Graph{} = g) do
  #   GenServer.cast(__MODULE__, {:redraw, g})
  # end


  ## GenServer callbacks
  ## -------------------------------------------------------------------




  # @impl Scenic.Scene
  # def handle_cast({:action, action}, {state, graph}) do
  #   IO.puts "#{inspect action}"
  #   GUI.Component.CommandBuffer.Reducer.process({state, graph}, action)
  #   |> case do
  #        :ignore_action
  #           -> {:noreply, {state, graph}}
  #        {:update_state, new_state} when is_map(new_state)
  #           -> {:noreply, {new_state, graph}}
  #        {:update_graph, %Scenic.Graph{} = new_graph}
  #           -> {:noreply, {state, new_graph}, push: new_graph}
  #        {:update_state_and_graph, {new_state, %Scenic.Graph{} = new_graph}} when is_map(new_state)
  #           -> {:noreply, {new_state, new_graph}, push: new_graph}
  #      end
  # end

  # @impl Scenic.Scene
  # def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
  #   Process.monitor(pid)

  #   new_component = {identifier, pid}
  #   new_ref_list = ref_list ++ [new_component]
  #   new_state = state |> Map.replace!(:component_ref, new_ref_list)

  #   {:reply, :ok, {new_state, graph}}
  # end

  # @impl Scenic.Scene
  # def handle_info({:DOWN, ref, :process, object, reason}, _state) do
  #   context = %{ref: ref, object: object, reason: reason}
  #   raise "Monitored process died. #{inspect context}"
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







  def initialize(%Frame{} = frame) do
    # the textbox is internal to the command buffer, but we need the
    # coordinates of it in a few places, so we pre-calculate it here
    textbox_frame =
      %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

    command_mode_background_color = :cornflower_blue
    component_id                  = :command_buffer
    # cursor_component_id           = {component_id, :cursor, 1}
    text_field_id                 = {component_id, :text_field}

    Draw.blank_graph()
    |> Scenic.Primitives.group(fn graph ->
         graph
         |> Draw.background(frame, command_mode_background_color)
         |> DrawingHelpers.draw_command_prompt(frame)
         |> DrawingHelpers.draw_input_textbox(textbox_frame)
        #  |> DrawingHelpers.draw_cursor(textbox_frame, id: cursor_component_id)
         |> DrawingHelpers.draw_text_field("", textbox_frame, id: text_field_id) #NOTE: Start with an empty string
    end, [
      id: component_id,
      hidden: true
    ])
  end
end
