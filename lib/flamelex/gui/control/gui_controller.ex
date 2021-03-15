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
  require Logger


  def start_link(_params) do
    viewport_size = Dimensions.new(:viewport_size)
    initial_state = GUIState.initialize(viewport_size)

    GenServer.start_link(__MODULE__, initial_state)
  end

  # def action(a) do
  #   GenServer.cast(__MODULE__, {:action, a})
  # end

  # def hide(x) do
  #   GenServer.cast(__MODULE__, {:hide, x})
  # end

  # def refresh(buf) do
  #   GenServer.cast(__MODULE__, {:refresh, buf})
  # end

  # def show_cmd_buf do
  #   GenServer.cast(__MODULE__, {:show, :command_buffer})
  # end

  # def hide_cmd_buf do
  #   GenServer.cast(__MODULE__, {:hide, :command_buffer})
  # end



  ## GenServer callbacks


  def init(state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    Flamelex.Utils.PubSub.subscribe(topic: :gui_update_bus)
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


  # def handle_cast({:switch_mode, m}, state) do
  #   # new_graph = default_gui(state)
  #   # Flamelex.GUI.redraw(new_graph)
  #   Logger.error "Need to forward this on to each buffer"
  #   {:noreply, state}
  # end

  def handle_cast({:action, :reset}, state) do
    new_graph = default_gui(state)
    Flamelex.GUI.redraw(new_graph)
    {:noreply, state}
  end

  #TODO maybe this doesn't need to be routed through here, but try it for now...
  def handle_cast({:refresh, %{ref: ref} = buf_state}, gui_state) do
    Logger.warn "I think this function might be deprecated..."
    ref
    |> GUiComponentRef.rego_tag()
    |> ProcessRegistry.find!()
    |> GenServer.cast({:refresh, buf_state, gui_state})

    {:noreply, gui_state}
  end







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










  # ignore GUI broadcasts to Buffers
  def handle_info({{:buffer, _details}, {:new_state, _buf_state}}, state) do
    Logger.warn "#{__MODULE__} ignoring a GUI broadcast to a buffer..."
    {:noreply, state}
  end

  # def handle_info(all_info, state) do
  #   IO.puts "BAD MASTVH?? #{inspect all_info}"
  #   {:noreply, state}
  # end

  def handle_info({:switch_mode, _m}, state) do
    {:noreply, state}
  end


end




  # def handle_cast({:show, {:command_buffer, _data}}, state) do


  #   #NOTE: Ok, so, this approach was wrong...
  #   #      our issue is that we need to change the mode to :command, and the
  #   #      instinct is to modify the graph here too - this is incorrect.
  #   #      API.CommandBuffer is a Scenic.Component responsible for managing it's
  #   #      own graph, so we have to forward on a msg to that component to
  #   #      make the change, but we can't actually do it here.

  #   # IO.puts "SHOW CMD BUF"
  #   # new_graph =
  #   #   state.graph
  #   #   |> IO.inspect(label: "LABEL: GRAPH")
  #   #   |> Scenic.Graph.modify(:command_buffer, &update_opts(&1, hidden: false))
  #   #   #TODO find where we add this group to this levels' graph & give it an id
  #   #   # |> Scenic.Graph.modify(:command_buffer, fn x ->
  #   #   #       IO.puts "WE'RE DOING IT"
  #   #   #       IO.inspect x
  #   #   # end)

  #   # Flamelex.GUI.RootScene.redraw(new_graph)
  #   Flamelex.GUI.Component.CommandBuffer.show

  #   {:noreply, state}
  # end
