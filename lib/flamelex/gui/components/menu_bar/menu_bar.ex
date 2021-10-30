defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.MenuBar

  import Flamelex.GUI.Utilities.Drawing.MenuBarHelper
  # use Scenic.Component

  #TODO deprecate these, but also come up eith a better name!!
  @left_margin 15
  @tab_width 190

  def height, do: 40
  def menu_item(:left_margin), do: 15
  def menu_item_width, do: 190

  def validate(data) do
    {:ok, data}
  end

  # def mount(%Scenic.Graph{} = graph, %{ref: r} = params) do
  #   graph |> add_to_graph(params, id: r) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  # end
  # def mount(%Scenic.Graph{} = graph, params) do
  #   graph |> add_to_graph(params) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  # end

  def action(a) do
    #TODO: We need some way of knowing that MenuBar has indeed been mounted
    #      somewhere, or else the messages just go into the void (use call instead of cast?)

    #REMINDER: `__MODULE__` will be the module which "uses" this macro
    GenServer.cast(__MODULE__, {:action, a})
  end

  def init(scene, params, opts) do

    Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

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
      |> assign(frame: params.frame)
      |> push_graph(new_graph)

    capture_input(new_scene, [:cursor_pos])

    {:ok, new_scene}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    frame |> inactive_menubar()
  end

  #TODO all of this is hacks... we need to move rego_tag into the behaviour, and this needs to be a behaviour
  # def rego_tag(%{ref: %BufRef{ref: ref}}) do
  #   rego_tag(ref)
  # end
  # def rego_tag(%{ref: aa}) when is_atom(aa) do
  #   rego_tag(aa)
  # end
  def rego_tag(x) do #TODO lol
    {:gui_component, x}
  end

  @doc """
  This function returns a map which describes all the menu items.
  """
  def menu_buttons_mapping do
    # top-level buttons
    %{
      "Flamelex" => %{
        "temet nosce" => {Flamelex, :temet_nosce, []},
        "show cmder" => {Flamelex.API.CommandBuffer, :show, []}
      },
      "Memex" => %{
        "random quote" => {Flamelex.Memex, :random_quote, []},
        "journal" => {Flamelex.Memex.Journal, :now, []}
      },
      "GUI" => %{}, #TODO auto-generate it from the GUI file
      "Buffer" => %{
        "open README" => {Flamelex.Buffer, :open!, []},
        "close" => {Flamelex.Buffer, :close, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
      },
      "DevTools" => %{},
      "Help" => %{},
    }
  end


    # def handle_cast({:action, action}, {%Scenic.Graph{} = graph, state}) do
    def handle_cast({:action, action}, scene) do
      case handle_action(scene, action) do
        #TODO this is actually kinda stupid now...
        :ignore_action
          -> {:noreply, scene}
        {:redraw_graph, %Scenic.Graph{} = new_graph}
          -> 
            new_scene =
              scene
              |> assign(graph: new_graph)
              # |> assign(frame: params.frame)
              |> push_graph(new_graph)
            
            {:noreply, new_scene}
        # {:update_frame, %Frame{} = new_frame}
        #   -> {:noreply, {graph, new_frame}}
        # {:update_graph_and_state, {%Scenic.Graph{} = new_graph, new_state}}
        #   -> 
        #     new_scene =
        #     scene
        #     |> assign(graph: new_graph)
        #     # |> assign(frame: params.frame)
        #     |> push_graph(new_graph)
          
        #   {:noreply, new_scene}
        #     {:noreply, {new_graph, new_state}, push: new_graph}
        # deprecated_return ->
        #   deprecated_return
      end
    end

  ##  handle_input callbacks


  @impl Scenic.Scene
  def handle_input({:cursor_pos, {_x, _y} = coords}, _context, frame) do
    case coords |> hovering_over_item?() do
      {:main_menubar, index} ->
          # Flamelex.Fluxus.fire_action({:animate_menu, index})
          MenuBar.action({:animate_menu, index})
          # GenServer.cast(__MODULE__, {:animate_menu, index})
          {:noreply, frame}
      {:sub_menu, index, sub_index} ->
          # Flamelex.Fluxus.fire_action({:animate_menu, index, sub_index})
          # MenuBar.action()
          {:noreply, frame}
    end
  end

  def handle_input({:cursor_button, {:left, :release, _dunno, coords}}, _context, frame) do
    case coords |> hovering_over_item?() do
      {:main_menubar, _index} ->
          # MenuBar.action({:animate_menu, index})
          {:noreply, frame}
      {:sub_menu, index, sub_index} ->
          # MenuBar.action({:call_function, index, sub_index})
          {:noreply, frame}
    end
  end

  def handle_input({:cursor_exit, _some_number}, _context, state) do
    # MenuBar.action(:reset_and_deactivate) #TODO how do we do this then?
    {:noreply, state}
  end


  def handle_input({:cursor_button, {:right, :press, _num?, _coords?}}, _context, state) do
    MenuBar.action(:reset_and_deactivate)
    {:noreply, state}
  end

  def handle_input({:cursor_button, anything_else}, _context, state) do
    # ignore it...
    {:noreply, state}
  end

  def handle_input(unmatched_input, _context, state) do
    {:noreply, state}
  end



  ##  handle_action callbacks


    #NOTE: How to develop a component
  #      Say I want to click on something &


  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({graph, frame}, {:hover, tab}) do
    {:redraw_graph, graph |> Draw.test_pattern()}
  end

  def handle_action({_graph, frame}, :reset_and_deactivate) do
    {:redraw_graph, inactive_menubar(frame)}
  end

  def handle_action({_graph, frame}, {:call_function, index, sub_index}) do

    {:ok, {key, first_sub_menu}} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index)
    # %{"paracelsize" => {Flamelex, :paracelsize, []}}
    {:ok, {_key, {m, f, a}}} = first_sub_menu |> Enum.fetch(sub_index)

    # {:ok, {m, f, _a} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index) |> Enum.fetch(sub_index)
    Kernel.apply(m, f, a)

    {:redraw_graph, inactive_menubar(frame)}
  end

  # def handle_action({graph, frame}, {:animate_menu, index}) do
  def handle_action(scene, {:animate_menu, index}) do
  # def handle_cast({graph, frame}, {:animate_menu, index}) do
    {:redraw_graph, draw_dropdown_menu(scene.assigns.graph, scene.assigns.frame, index, _sub_index = 0)}
  end

  def handle_action({graph, frame}, {:animate_menu, index, sub_index}) do
    {:redraw_graph, draw_dropdown_menu(graph, frame, index, sub_index)}
  end

  #NOTE: this last handle_action/2 catches actions that didn't match on one of the above
  def handle_action({_graph, frame}, action) do
    :ignore_action
  end
end
