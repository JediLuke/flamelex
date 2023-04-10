defmodule Flamelex.GUI.Components.WidgetWkb do
    use Scenic.Component
    alias ScenicWidgets.Core.Structs.Frame
    require Logger
 
    @elixir_location "/Users/luke/.asdf/installs/elixir/1.14.0"
  
    def validate(%{frame: %Frame{} = _f, state: _state} = data) do
       #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
       {:ok, data}
    end
 
    def init(scene, args, opts) do
 
        #TODO should we use args.state here???
        init_state = %{
            widget: nil,
            mode: :popped_out
            # widget_pos: {250, 250}, # starting position of the widget
            # widget: %{
            #     frame: Frame.new(
            #         pin: {400, 200},
            #         size: {500, 500}
            #     ),
            #     state: %{}
            # }
        }

       init_graph =
          render(args.frame, init_state)
 
       init_scene = scene
          |> assign(state: args.state)
          |> assign(frame: args.frame)
          |> assign(graph: init_graph)
          |> push_graph(init_graph)

          request_input(init_scene, [:cursor_pos])
 
       Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
 
       {:ok, init_scene}
    end

    # def handle_cast(:re_render, %{assigns: %{widget: %{frame: widget_frame, state: widget_state}}}) do
    def handle_cast(:re_render, scene) do

        new_graph =
            render(scene.assigns.frame, scene.assigns.state)

        new_scene = scene
            # |> assign(state: args.state)
            # |> assign(frame: args.frame)
            |> assign(graph: new_graph)
            |> push_graph(new_graph)
        
        {:noreply, new_scene}
    end
 
    def handle_info({:radix_state_change, _new_radix_state}, %{assigns: %{state: _current_state}} = scene) do
       # ignoring a RadixState update...
       {:noreply, scene}
    end
 
    def handle_event({:click, :new_widget} = event, _from, scene) do
        IO.puts("NEW WIDGET was clicked!")

        new_widget = %{
                frame: Frame.new(
                    pin: {400, 200},
                    size: {500, 500}
                ),
                state: %{}
            }

        new_state = scene.assigns.state
        |> Map.merge(%{widget: new_widget, mode: :popped_out})

        re_render()

        # {:cont, event, state |> }
        {:cont, event, scene |> assign(state: new_state)}
      end

    def handle_event({:click, :toggle_wkb_mode} = event, _from, scene) do
        IO.puts("SSWAP MODEd!")

        # new_widget = %{
        #         frame: Frame.new(
        #             pin: {400, 200},
        #             size: {500, 500}
        #         ),
        #         state: %{}
        #     }

        new_state = scene.assigns.state
        |> Map.merge(%{mode: inverse_mode(scene.assigns.state)})

        re_render()

        # {:cont, event, state |> }
        {:cont, event, scene |> assign(state: new_state)}
    end

    def inverse_mode(%{mode: :popped_out}), do: :popped_in
    def inverse_mode(%{mode: :popped_in}), do: :popped_out

    def re_render do
        GenServer.cast(self(), :re_render)
    end

    #TODO take in the frame, apply a scissor around the whole thing

    #TODO we could also manage scroll at this layer
    def render(%Frame{} = frame, state) when is_map(state) do

        border_size = 12

       Scenic.Graph.build()
       |> Scenic.Primitives.group(fn graph ->
          graph
          |> render_border(frame, border_size, :gray)
          |> render_workbench(frame, border_size, state)
       end, [
          id: __MODULE__,
          translate: frame.pin,
          scissor: frame.size
       ])
    end
 
    def render_border(graph, %{size: {w, h}}, size, color) do
        graph
        # top and bottom bars
        |> Scenic.Primitives.rect({w, size}, fill: color, translate: {0, 0})
        |> Scenic.Primitives.rect({w, size}, fill: color, translate: {0, h-size})
        # left and right bars
        |> Scenic.Primitives.rect({size, h}, fill: color, translate: {0, 0})
        |> Scenic.Primitives.rect({size, h}, fill: color, translate: {w-size, 0})
    end

    def render_workbench(graph, %{size: {_w, _h}}, _size, state) do

        # inner_frame = 

        graph
        |> do_render_wkb(state)
    end



    def do_render_wkb(graph, %{widget: nil}) do
        graph |> do_render_wkb(:no_widget)
        # graph
        # |> Scenic.Primitives.text("Widget Workbench!",
        #     translate: {70, 120},
        #     font_size: 36, fill: :light_green)
        # |> Scenic.Components.button("new Widget", id: :new_widget, t: {50, 50})
    end

    def do_render_wkb(graph, %{mode: m, widget: widget}) do
        graph
        |> render_outer_graph_panel(widget)
        |> render_widget(m, widget)
    end

    def render_outer_graph_panel(graph, widget) do
        text = "Outer frame: #{inspect widget.frame}"
        graph
        |> Scenic.Primitives.text(text,
            translate: {250, 120},
            font_size: 36, fill: :yellow)
        |> Scenic.Components.button("Toggle workbench mode", id: :toggle_wkb_mode, t: {10, 10})
    end

    #TODO it shouldn't be possible to have state be an empty map... but anyway
    def do_render_wkb(graph, %{}) do
        IO.puts "BLANK STATE"
        graph |> do_render_wkb(:no_widget)
    end

    def do_render_wkb(graph, :no_widget) do
        graph
        |> Scenic.Primitives.text("Widget Workbench!",
            translate: {70, 120},
            font_size: 36, fill: :light_green)
        |> Scenic.Components.button("new Widget", id: :new_widget, t: {50, 50})
    end
    
    def render_widget(graph, :popped_out, %{frame: frame, state: state} = widget) do


        #TODO & --HERE-- is where, we can inject *anything*, as long
        # as it's a --render function-- with a certain /interface/
        render_fn = &default_widget/2
        

        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> render_fn.(widget)
            |> render_workbench_overlay(widget)
         end, [
            id: :workbench,
            translate: frame.pin,
            scissor: frame.size
         ])
    end

    def render_widget(graph, :popped_in, %{frame: frame, state: state} = widget) do


        #TODO & --HERE-- is where, we can inject *anything*, as long
        # as it's a --render function-- with a certain /interface/
        render_fn = &default_widget/2
        

        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> render_fn.(widget)
            # |> render_workbench_overlay(widget)
         end, [
            id: :workbench,
            translate: frame.pin,
            scissor: frame.size
         ])
    end

    def default_widget(graph, %{frame: frame}) do
        graph
        |> Scenic.Primitives.rect(frame.size, fill: :red)
    end

    def render_workbench_overlay(graph, %{frame: frame}) do
        graph
        |> render_border(frame, 5, :green)
        |> render_hover_circle()
    end

    def render_hover_circle(graph) do
        graph
        |> Scenic.Primitives.circle(20, stroke: {3, :green}, fill: :light_green, translate: {40, 40})
    end

 end