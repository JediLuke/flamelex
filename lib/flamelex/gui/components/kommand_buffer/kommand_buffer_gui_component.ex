defmodule Flamelex.GUI.Component.KommandBuffer do
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.KommandBuffer.Utils, as: KommandBufrUtils
  require Logger


  def height, do: 32




  def validate(data) do
    {:ok, data}
  end


  def init(scene, params, opts) do

    # Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()


    ProcessRegistry.register({:gui_component, KommandBuffer})

    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    new_graph = 
      render(params.frame, %{})


      # new_graph = 
      # Scenic.Graph.build()
      # |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    new_scene =
      scene
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:ok, new_scene}
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


  # # def handle_cast(:show, {graph, state}) do #TODO components have ordering reversed :( it should be {state, graph} to be consistent with the rest of the application
  # def handle_cast(vis = :show, scene) do #TODO components have ordering reversed :( it should be {state, graph} to be consistent with the rest of the application
  #   new_scene = update_visibility(scene, vis)
  #   {:noreply, new_scene}
  # end


  def handle_cast(vis, scene) when vis in [:show, :hide] do
    Logger.debug "#{__MODULE__} - GUI got msg to `#{inspect vis}` the KommandBuffer..."
    new_graph = scene.assigns.graph |> KommandBufrUtils.set_visibility(vis)
    new_scene = scene
      |> assign(graph: new_graph)
      |> push_graph(new_graph)
    {:noreply, new_scene}
  end


  def handle_cast({:update, %{data: new_text, move_cursor: cursor_move_details}}, scene) do

    # update the text
    {:gui_component, {KommandBufferGUI, TextBox}}
    |> ProcessRegistry.find!()
    |> GenServer.call({:modify, :lines, [%{line: 1, text: new_text}]})

    # move the cursor
    {:text_cursor, 1, {:gui_component, {KommandBufferGUI, TextBox}}}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move, %{instructions: cursor_move_details}})

    {:noreply, scene}
  end

  def handle_cast(:clear, scene) do
    # update the text
    {:gui_component, {KommandBufferGUI, TextBox}}
    |> ProcessRegistry.find!()
    |> GenServer.call({:modify, :lines, [%{line: 1, text: ""}]})

    # move the cursor
    {:text_cursor, 1, {:gui_component, {KommandBufferGUI, TextBox}}}
    |> ProcessRegistry.find!()
    |> GenServer.cast(:reset)

    {:noreply, scene}
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
