defmodule Flamelex.GUI.Component.KommandBuffer do
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.KommandBuffer.Utils, as: KommandBufrUtils
  require Logger


  def height, do: 32


  def rego_tag(_params) do
    {:gui_component, KommandBuffer}
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


  def handle_cast({:update, %{data: new_text}}, graph_state) do
    IO.puts "GUI COMP GETTING MSG #{inspect new_text}"

    {:gui_component, {KommandBufferGUI, TextBox}}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:modify, :lines, [%{line: 1, text: new_text}]})

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
