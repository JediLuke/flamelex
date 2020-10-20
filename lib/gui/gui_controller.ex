defmodule Flamelex.GUI.Controller do
  @moduledoc """
  This process is in some ways the equal-opposite of OmegaMaster. That process
  holds all our buffers & manipulates them. This process holds the actual
  %RootScene{} and %Layout{}, as well as keeping track of open buffers etc.
  """
  use GenServer
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Structs.GUIControlState, as: State
  alias GUI.Component.MenuBar
  require Logger
  import Flamelex.GUI.Utilities.ControlHelper



  def start_link(_params) do
    viewport_size = Dimensions.new(:viewport_size)
    initial_state = State.initialize(viewport_size)

    GenServer.start_link(__MODULE__, initial_state)
  end

  def action(a) do
    Logger.debug "action: `#{inspect a}` sent to GUI.Controller..."
    GenServer.cast(__MODULE__, {:action, a})
  end

  def show(x) do
    GenServer.cast(__MODULE__, {:show, x})
  end


  ## GenServer callbacks


  def init(state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, state, {:continue, :draw_default_gui}}
  end

  def handle_continue(:draw_default_gui, state) do

    #TODO
    #NOTE: This is here because sometimes, when we restart the app, I think
    #      this process is trying to re-draw th GUI before the RootScene is ready
    :timer.sleep(50)

    new_graph = default_gui(state)
    Flamelex.GUI.redraw(new_graph)

    {:noreply, %{state|graph: new_graph}}
  end

  def handle_cast({:action, :reset}, state) do
    new_graph = default_gui(state)
    Flamelex.GUI.redraw(new_graph)
    {:noreply, state}
  end




  # def handle_cast(:show_in_gui, %Buffer{} = buffer}, state) do

  #   # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

  #   # new_state =
  #   #   state
  #   #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
  #   #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

  #   # IO.puts "SENDING --- #{new_state.active_buffer.content}"
  #   GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

  #   {:noreply, state}
  # end




  def handle_cast({:action, action}, state) do
    case GUI.Root.Reducer.process(state, action) do
      # :ignore_action
      #     -> {:noreply, {scene, graph}}
      # {:update_state, new_scene} when is_map(new_scene)
      #     -> {:noreply, {new_scene, graph}}
      {:redraw_root_scene, %{graph: new_graph} = new_state}  ->
        Flamelex.GUI.RootScene.redraw(new_graph)
        {:noreply, new_state}
      # {:update_state_and_graph, {new_scene, %Scenic.Graph{} = new_graph}} when is_map(new_scene)
      #     -> {:noreply, {new_scene, new_graph}, push: new_graph}
    end
  end

  def handle_call(:get_frame_stack, _from, state) do
    {:reply, state.layout.frames, state}
  end

  def handle_cast({:show, {:buffer, filename} = buf}, state) do

    data  = Buffer.read(buf)
    frame = calculate_framing(filename, state.layout)

    new_graph =
      state.graph
      |> GUI.Component.TextBox.draw({frame, data})
      # |> Draw.test_pattern()

    Flamelex.GUI.RootScene.redraw(new_graph)

    {:noreply, %{state|graph: new_graph}}
  end



  def calculate_framing(name, %Layout{
    arrangement: :maximized,
    dimensions: %Dimensions{height: h, width: w} = layout_dimens,
    frames: [], #NOTE: No existing frames
    opts: opts
  }) do
    coords = calculate_frame_position(opts)
    dimens = calculate_frame_size(opts, layout_dimens)

    Frame.new(name, coords, dimens)
  end

  def calculate_frame_position(opts) do
    case opts |> Map.fetch(:show_menubar?) do
      {:ok, true} ->
        Coordinates.new(x: 0, y: MenuBar.height())
      _otherwise ->
        Coordinates.new(x: 0, y: 0)
    end
  end

  def calculate_frame_size(opts, layout_dimens) do
    case opts |> Map.fetch(:show_menubar?) do
      {:ok, true} ->
        Dimensions.new(width: layout_dimens.width, height: layout_dimens.height - MenuBar.height())
      _otherwise ->
        Dimensions.new(width: layout_dimens.width, height: layout_dimens.height)
    end
  end










  # def handle_cast({:register_new_buffer, [type: :text, content: c, action: 'OPEN_FULL_SCREEN'] = args}, %{
  #   buffer_list: [] # the case where we have no open buffers
  # } = state) do


  #   new_state =
  #     state
  #     |> Map.update!(:buffer_list, fn _b -> [1] end) #TODO have a buffer struct I guess...

  #   #TODO call Scenic GUI component process (registered to this topic/whatever) &
  #   GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: c]})

  #   {:noreply, new_state}
  # end

  # def handle_cast({:show_fullscreen, %Buffer{} = buffer}, state) do
  def handle_cast({:show_fullscreen, buffer}, state) do

    # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

    # new_state =
    #   state
    #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
    #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

    # IO.puts "SENDING --- #{new_state.active_buffer.content}"
    # GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.data]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    {:noreply, state}
  end


  # @impl true
  # def handle_info(:check_reminders, state) do
  #   # Logger.info("Checking reminders...")
  #   state =
  #     Utilities.Data.find(tags: "reminder") |> process_reminders(state)
  #   Process.send_after(self(), :check_reminders, :timer.seconds(10))
  #   {:noreply, state}
  # end

  # def handle_info({:reminder!, r}, state) do
  #   Logger.warn "REMINDING YOU ABOUT! - #{inspect r}"
  #   #TODO right now, schedule to remind me again (so I don't forget) - when it's acknowledged, this will stop
  #   Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
  #   {:noreply, state}
  # end

end
