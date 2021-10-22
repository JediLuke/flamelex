defmodule Flamelex.GUI.Component.KommandBuffer do
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.KommandBuffer.Utils, as: KommandBufrUtils
  require Logger


  def height, do: 32


  def rego_tag(_params) do
    {:gui_component, KommandBuffer}
  end


  def validate(data) do
    IO.inspect data, label: "MENU BAR"
    {:ok, data}
  end


  def init(scene, params, opts) do

    IO.puts "YEH WE BE INITIN"
    # IO.inspect params
    # IO.inspect opts
    # Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    new_graph = 
      render(params.frame, %{})

    IO.inspect new_graph

      # new_graph = 
      # Scenic.Graph.build()
      # |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    # # new_scene =
      scene
    #   # |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:ok, scene}
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(params) do

    #TODO manually test this & remind myself what kind of msg gets sent
    Process.monitor(Process.whereis(KommandBuffer)) # if KommandBuffer crashes, we crash!

    # res = Flamelex.Utils.PubSub.subscribe(topic: :gui_event_bus)
    params |> Map.merge(%{
      contents: "",
      draw_footer?: false # NOTE: enforce this here, see what happens...
    })
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    KommandBufrUtils.default_kommand_buffer_graph(frame)
  end


  def handle_cast(:show, {graph, state}) do #TODO components have ordering reversed :( it should be {state, graph} to be consistent with the rest of the application
    Logger.debug "#{__MODULE__} - GUI got msg to :show the KommandBuffer..."
    new_graph = graph |> KommandBufrUtils.set_visibility(:show)
    {:noreply, {new_graph, state}, push: new_graph}
  end


  def handle_cast(:hide, {graph, state}) do
    new_graph = graph |> KommandBufrUtils.set_visibility(:hide)
    {:noreply, {new_graph, state}, push: new_graph}
  end


  def handle_cast({:update, %{data: new_text, move_cursor: cursor_move_details}}, graph_state) do

    # update the text
    {:gui_component, {KommandBufferGUI, TextBox}}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:modify, :lines, [%{line: 1, text: new_text}]})

    # move the cursor
    {:text_cursor, 1, {:gui_component, {KommandBufferGUI, TextBox}}}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move, %{instructions: cursor_move_details}})

    {:noreply, graph_state}
  end


  #TODO so, we should be able to just, subscribe to mode changes... dunno why it's not working
  def handle_info({:switch_mode, m}, state) do
    IO.puts "KOMMAND MSG - #{inspect m}"
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, _not_sure, _dunno, _cant_remember}, state) do
    Logger.error "#{__MODULE__} received a :DOWN message."
    {:noreply, state}
  end
end
