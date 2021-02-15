defmodule Flamelex.GUI.Controller do
  @moduledoc """
  This process is in some ways the equal-opposite of BufferManager. That process
  holds all our buffers & manipulates them. This process holds the actual
  %RootScene{} and %Layout{}, as well as keeping track of open buffers etc.
  """
  use GenServer
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Structs.{GUIState, GUiComponentRef}
  import Flamelex.GUI.Utilities.ControlHelper


  def start_link(_params) do
    viewport_size = Dimensions.new(:viewport_size)
    initial_state = GUIState.initialize(viewport_size)

    GenServer.start_link(__MODULE__, initial_state)
  end

  def action(a) do
    GenServer.cast(__MODULE__, {:action, a})
  end

  def hide(x) do
    GenServer.cast(__MODULE__, {:hide, x})
  end

  def refresh(buf) do
    GenServer.cast(__MODULE__, {:refresh, buf})
  end

  def show_cmd_buf do
    GenServer.cast(__MODULE__, {:show, :command_buffer})
  end

  def hide_cmd_buf do
    GenServer.cast(__MODULE__, {:hide, :command_buffer})
  end

  def switch_mode(m) do
    GenServer.cast(__MODULE__, {:switch_mode, m})
  end



  ## GenServer callbacks


  def init(state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    # PubSub.subscribe(topic: :active_buffer) #TODO?
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

  def handle_call(:get_frame_stack, _from, state) do
    {:reply, state.layout.frames, state}
  end

  def handle_cast({:action, :reset}, state) do
    new_graph = default_gui(state)
    Flamelex.GUI.redraw(new_graph)
    {:noreply, state}
  end

  # def handle_cast({:switch_mode, m}, gui_state) do



  #   new_graph = gui_state.graph |> Draw.test_pattern()
  #   Flamelex.GUI.redraw(new_graph)
  #   {:noreply, gui_state}
  # end




  # def handle_cast(:show_in_gui, %BufRef{} = buffer}, state) do

  #   # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

  #   # new_state =
  #   #   state
  #   #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
  #   #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

  #   # IO.puts SENDING --- #{new_state.active_buffer.content}"
  #   Flamelex.GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

  #   {:noreply, state}
  # end




  # def handle_cast({:action, action}, state) do
  #   case Flamelex.GUI.Root.Reducer.process(state, action) do
  #     # :ignore_action
  #     #     -> {:noreply, {scene, graph}}
  #     # {:update_state, new_scene} when is_map(new_scene)
  #     #     -> {:noreply, {new_scene, graph}}
  #     {:redraw_root_scene, %{graph: new_graph} = new_state}  ->
  #       Flamelex.GUI.RootScene.redraw(new_graph)
  #       {:noreply, new_state}
  #     # {:update_state_and_graph, {new_scene, %Scenic.Graph{} = new_graph}} when is_map(new_scene)
  #     #     -> {:noreply, {new_scene, new_graph}, push: new_graph}
  #   end
  # end



  def handle_cast({:show, buf_state}, gui_state) do #TODO this assumes it isn't hibernated or whatever

    frame = Frame.new(gui_state, buf_state)
    # data  = Buffer.read(buf)

    gui_component_process_alive? = false
    if gui_component_process_alive? do
      raise "well that's a surprise"
    else
      new_graph =
        gui_state.graph
        |> Flamelex.GUI.Component.TextBox.mount(
             buf_state
             |> Map.merge(%{
                  ref: buf_state.rego_tag,
                  frame: frame,
                  mode: :normal
             }))

      Flamelex.GUI.RootScene.redraw(new_graph)
      {:noreply, %{gui_state|graph: new_graph}}
    end
  end

  def handle_cast({:show, {:command_buffer, _data}}, state) do


    #NOTE: Ok, so, this approach was wrong...
    #      our issue is that we need to change the mode to :command, and the
    #      instinct is to modify the graph here too - this is incorrect.
    #      API.CommandBuffer is a Scenic.Component responsible for managing it's
    #      own graph, so we have to forward on a msg to that component to
    #      make the change, but we can't actually do it here.

    # IO.puts "SHOW CMD BUF"
    # new_graph =
    #   state.graph
    #   |> IO.inspect(label: "LABEL: GRAPH")
    #   |> Scenic.Graph.modify(:command_buffer, &update_opts(&1, hidden: false))
    #   #TODO find where we add this group to this levels' graph & give it an id
    #   # |> Scenic.Graph.modify(:command_buffer, fn x ->
    #   #       IO.puts "WE'RE DOING IT"
    #   #       IO.inspect x
    #   # end)

    # Flamelex.GUI.RootScene.redraw(new_graph)
    Flamelex.GUI.Component.CommandBuffer.show

    {:noreply, state}
  end

  # def handle_cast({:hide, :command_buffer}, state) do

  #   new_graph =
  #     state.graph
  #     |> Scenic.Graph.modify(:command_buffer, &update_opts(&1, hidden: true))

  #   Flamelex.GUI.RootScene.redraw(new_graph)

  #   {:noreply, %{state|graph: new_graph}}
  # end

  # def handle_cast({:show, {:buffer, name} = buf}, state) do #TODO this is implicitely assuming we want a text buffer

  #   data  = Buffer.read(buf)
  #   frame = calculate_framing(name, state.layout)

  #   new_graph =
  #     state.graph
  #     #TODO this is the part of CommandBu
  #     # |> Flamelex.GUI.Component.TextBox.draw({frame, data, %{}})
  #     # |> Frame.draw(frame)
  #     # # |> Draw.test_pattern()

  #   Flamelex.GUI.RootScene.redraw(new_graph)

  #   {:noreply, %{state|graph: new_graph}}
  # end


  #TODO maybe this doesn't need to be routed through here, but try it for now...
  def handle_cast({:refresh, %{ref: ref} = buf_state}, gui_state) do
    ref
    |> GUiComponentRef.rego_tag()
    |> ProcessRegistry.find!()
    |> GenServer.cast({:refresh, buf_state, gui_state})

    {:noreply, gui_state}
  end





    # new_graph =
    #   state.graph
    #   |> Flamelex.GUI.Component.TextBox.draw({frame, data})


    # case Flamelex.GUI.Root.Reducer.process(state, action) do
    #   # :ignore_action
    #   #     -> {:noreply, {scene, graph}}
    #   # {:update_state, new_scene} when is_map(new_scene)
    #   #     -> {:noreply, {new_scene, graph}}
    #   {:redraw_root_scene, %{graph: new_graph} = new_state}  ->
    #     Flamelex.GUI.RootScene.redraw(new_graph)
    #     {:noreply, new_state}
    #   # {:update_state_and_graph, {new_scene, %Scenic.Graph{} = new_graph}} when is_map(new_scene)
    #   #     -> {:noreply, {new_scene, new_graph}, push: new_graph}







  # def handle_cast({:register_new_buffer, [type: :text, content: c, action: 'OPEN_FULL_SCREEN'] = args}, %{
  #   buffer_list: [] # the case where we have no open buffers
  # } = state) do


  #   new_state =
  #     state
  #     |> Map.update!(:buffer_list, fn _b -> [1] end) #TODO have a buffer struct I guess...

  #   #TODO call Scenic GUI component process (registered to this topic/whatever) &
  #   Flamelex.GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: c]})

  #   {:noreply, new_state}
  # end

  # def handle_cast({:show_fullscreen, %BufRef{} = buffer}, state) do
  def handle_cast({:show_fullscreen, buffer}, state) do

    # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

    # new_state =
    #   state
    #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
    #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

    # IO.puts "SENDING --- #{new_state.active_buffer.content}"
    # Flamelex.GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    Flamelex.GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.data]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    {:noreply, state}
  end


  # @impl true
  # def handle_info({:active_buffer, :SWITCH_mode, _mode}, state) do
  #   IO.puts "GUI controller ignoring switch mode cmd, since that will propagate via buffers themselves"
  #   {:noreply, state}
  # end


  def handle_info(all_info, state) do
    IO.puts "BAD MASTVH?? #{inspect all_info}"
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
