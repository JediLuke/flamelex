defmodule Flamelex.GUI.Controller do
  @moduledoc """
  This process is in some ways the equal-opposite of BufferManager. That process
  holds all our buffers & manipulates them. This process holds the actual
  %RootScene{} and %Layout{}, as well as keeping track of open buffers etc.
  """
  use GenServer
  use Flamelex.ProjectAliases
  # alias Flamelex.GUI.Structs.GUIState
  alias Flamelex.GUI.Utils.DefaultGUI
  alias Flamelex.GUI.Component.TextBox
  require Logger

  # just do it simple - a stack of frames. Frames are kind of analogous to layers, but they have restrictions on size
  # can be put on top/over eachother
  # can overlap
  # can be dragged/moved, can be toggled visible/inisible, can be moved around (re-ordered)
  # frames have layouts - can contain splits / hjave alignments / margins etc


  ## OK I figured it OUT !!
  #
  #  The GUI.Controller keeps the highest level state of the GUI:
  #    - Layers, which have layouts
  #    - Frames inside those layers
  #    - Inside frames, it renders Components
  #    - GUI.State - this is a struct which holds GUI-specific state.
  #      Note that state is NOT things like layouts - state is an
  #      *internal* property of this process, so it keeps track of like,
  #      where we hover etc.


  def start_link(_params) do
    initial_state = %{
      # viewport: Dimensions.new(:viewport_size), #TODO call RootScene & get this - might improve sync on startup aswell!
      frames: [],
      graph: nil,
      show_menubar?: true,
      memex_graph: nil,
      mode: :homebase # ok maybe this mode/state thing is getting out of hand...
                      # `:homebase` mode means we're rendering the usual
                      # text editor kind of stuff, :memex mode means we're
                      # rendering the memex
    }

    GenServer.start_link(__MODULE__, initial_state)
  end

  def toggle_layer(x) do
    # "This is what I can use to manually test the layers concept..."
    GenServer.cast(__MODULE__, {:toggle_layer, x})
  end

  def mode do
    GenServer.call(__MODULE__, :get_mode)
  end


  #
  #
  ## GenServer callbacks
  #
  #


  def init(state) do
    Logger.debug "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)

    # request_input(new_scene, [:cursor_pos, :cursor_button])
    Flamelex.Utils.PubSub.subscribe(topic: :gui_update_bus)
    {:ok, state, {:continue, :draw_default_gui}}
  end

  def handle_continue(:draw_default_gui, state) do
    #TODO: I'm putting this sleep here because sometimes when I boot up
    #      the app, the graph never renders, and I think that maybe the
    #      GUI.Controller is sending the message out into the BEAmether,
    #      but GUI.RootScene hasn't booted yet - we should enforce that
    #      the process exists or something
    :timer.sleep(500)

    {:ok, vp} = GenServer.call(Flamelex.GUI.RootScene, :get_viewport)
    IO.inspect vp, label: "REAL VIEWPORT BBY"

    # state = state |> Map.merge(%{viewport: vp})

    # size = vp |> Keyword.get(:size)
    # vp_dimensions = Dimensions.new(vp.size)

    state = state |> Map.merge(%{viewport: vp})

    new_graph = DefaultGUI.draw(state)
    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
    {:noreply, %{state|graph: new_graph}}
  end

  def handle_call(:get_mode, _from, state) do
    {:reply, state.mode, state}
  end

  # def handle_call(:get_frame_stack, _from, state) do
  #   {:reply, state.layout.frames, state}
  # end


  # def handle_cast({:switch_mode, m}, state) do
  #   # new_graph = DrawDefaultGUI.default_gui(state)
  #   # Flamelex.GUI.redraw(new_graph)
  #   Logger.error "Need to forward this on to each buffer"
  #   {:noreply, state}
  # end

  # def handle_cast({:action, :reset}, state) do
  #   #TODO this should - query the buffers etc, and attempt tp re-draw it
  #   # failing that, this is the controller - this :reset ought to just,
  #   # re-draw the GUI from the existing state, more like a refresh
  #   new_graph = DrawDefaultGUI.default_gui(state)
  #   Flamelex.GUI.redraw(new_graph)
  #   {:noreply, state}
  # end

  # #TODO maybe this doesn't need to be routed through here, but try it for now...
  # def handle_cast({:refresh, %{ref: ref} = buf_state}, gui_state) do
  #   Logger.warn "I think this function might be deprecated..."
  #   ref
  #   |> GUiComponentRef.rego_tag()
  #   |> ProcessRegistry.find!()
  #   |> GenServer.cast({:refresh, buf_state, gui_state})

  #   {:noreply, gui_state}
  # end

  def handle_cast({:close, buffer_tag} = msg, state) do
    Logger.debug "#{__MODULE__} received msg: #{inspect msg}"

    #TODO ok so, if this was as good as MenuBar, then we would just -
    #     update the `state` of GUIController, re-render it, & we're
    #     done.
    #
    #     For now I'm going to go with hax

    # WOW - this actually works
    new_graph =
      state.graph
      |> Scenic.Graph.delete(buffer_tag) #TODO here we want to remove the open buffer TextBox component, when the buffer closes, so the GUI changes

    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
    {:noreply, %{state|graph: new_graph}}
  end

  def handle_cast(:open_memex, %{mode: :homebase, memex_graph: nil} = state) do
    Logger.debug "#{__MODULE__} recv'd msg: :open_memex"

    # new_graph = render_memex()

    new_graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.MemexScreen.add_to_graph(%{ #TODO wonder if `add_to_graph` could become mount/3 - of even mount/2, just pass everything in as a fkin map!! %{id: blah, data: blah}
            frame: Frame.new(state.viewport)
         }, id: :memex_screen)

    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
    #TODO I guess it could be better to just hand *everything*
    #     down to StageManager - have that process update the
    #     root scene etc :thinking_face:
    GenServer.cast(Flamelex.GUI.StageManager.Memex, :memex_open)

    {:noreply, %{state|memex_graph: new_graph, mode: :memex}}
  end

  def handle_cast(:open_memex, %{mode: :homebase, memex_graph: %Scenic.Graph{} = memex_graph} = state) do
    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, memex_graph})
    {:noreply, %{state|mode: :memex}}
  end

  # def handle_cast(:close_memex, %{memex_graph: true} = state) do
  #   old_graph = state.assigns.graph
  #   GenServer.cast(Flamelex.GUI.RootScene, {:redraw, old_graph})
  #   {:noreply, %{state|mode: :homebase}}
  # end

  def handle_cast({:activate, :homebase}, %{mode: :memex} = state) do
    old_graph = state.graph
    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, old_graph})
    {:noreply, %{state|mode: :homebase}}
  end

  def render_memex() do
    Logger.warn "DEPRECATE ME"
    tidbit = Memex.My.Wiki.list |> Enum.random() #TODO My.Wiki.random()
    # IO.inspect(tidbit, label: "TB")

    Scenic.Graph.build()
    |> Scenic.Primitives.text("HexDocs",
          font: :ibm_plex_mono,
          translate: {80, 200}, # text draws from bottom-left corner??
          font_size: 36,
          fill: :green )
    |> Scenic.Primitives.text("Memex",
          font: :ibm_plex_mono,
          translate: {80, 400}, # text draws from bottom-left corner??
          font_size: 36,
          fill: :green )
    |> Scenic.Components.button("Random", id: :sample_btn_id, t: {10, 10})
    |> Flamelex.GUI.Component.HyperCard.add_to_graph(%{
          tidbit: tidbit,
          ref: "Luke's HyperCard" })
  end


  def filter_event(event, _from, state) do
    IO.puts("Sample button was clicked! #{inspect event}")
    new_graph = render_memex()
    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
    {:noreply, %{state|memex_graph: new_graph, mode: :memex}}
    # {:noreply, state}
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

  def handle_cast(:swap_layer_2_and_3, gui_state) do
    #TODO this is just temporary, for testing - might be impssible and probably isnt needed

    layer_2 = gui_state.graph.primitives |> find_layer(1) # extract lower frame  & save in a variable
    layer_1 = gui_state.graph.primitives |> find_layer(2) # and uppder frame, at least make the reference to it for later use

    # copy the higher frame into the lower one
    new_graph =
      gui_state.graph
      |> Scenic.Graph.modify({:layer, :renseijen, 1}, fn _p ->
            layer_1
      end)
      |> Scenic.Graph.modify({:layer, :work_layer, 2}, fn _p ->
            layer_2
      end)

    # overwrite the higher frame, with the saved version we cached above

    # redraw

    {:noreply, %{gui_state|graph: new_graph}, push: new_graph}
  end

  def handle_cast({:toggle_layer, x}, gui_state) do

    layer = {:layer, :test, x}

    # look in the graph, find this primitive, & extract it's `hidden?` option field
    %{ids: %{^layer => [n]}, primitives: p} = gui_state.graph

    currently_hidden? =
        # Scenic doesn't really encourage you reading back from the Graph...
        if Map.has_key?(p[n], :styles) do
          case p[n].styles do
            %{hidden: hidden?} when is_boolean(hidden?) ->
                hidden?
            _otherwise ->
                false
          end
        else
          false
        end

    new_graph =
      gui_state.graph
      |> Scenic.Graph.modify(layer, &Scenic.Primitives.update_opts(&1, hidden: not currently_hidden?))

    GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})

    {:noreply, %{gui_state|graph: new_graph}}
  end


  def handle_cast({:show, buf_state}, gui_state) do #TODO this assumes it isn't hibernated or whatever

    # frame = Frame.new(gui_state, buf_state, scale: :half_height)
    frame = Frame.new(gui_state, buf_state)
    # data  = Buffer.read(buf)

    gui_component_process_alive? = false #TODO
    # sidebar: I think this was because `:show` could just mean, bring
    #          up a buffer which is already open
    if gui_component_process_alive? do
      raise "well that's a surprise"
    else
      new_graph =
        gui_state.graph
        |> TextBox.add_to_graph(
             buf_state |> Map.merge(%{
                  ref: buf_state.rego_tag, #NOTE: this becomes the id of this Scenic primitive
                  frame: frame,
                  mode: :normal,
                  draw_footer?: true }),
             id: buf_state.rego_tag)

      # Flamelex.GUI.RootScene.redraw(new_graph)
      GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
      {:noreply, %{gui_state|graph: new_graph}}
    end
  end


  def handle_cast({:hide, _buf}, state) do

    raise "cant hide yet but we should be able to!"
    # new_graph =
    #   state.graph
    #   |> Scenic.Graph.modify(
    #                     KommandBuffer,
    #                     &Scenic.Primitives.update_opts(&1, hidden: true))

    # Flamelex.GUI.RootScene.redraw(new_graph)

    # {:noreply, %{state|graph: new_graph}}
  end

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
    # ignore...
    {:noreply, state}
  end


  # private functions


  defp find_layer(primitives, x) do
    primitives
    |> Enum.find(fn
          {:layer, _name, ^x} ->
              true
          _p ->
              false
       end)
  end
end




  # def handle_cast({:show, {:kommand_buffer, _data}}, state) do


  #   #NOTE: Ok, so, this approach was wrong...
  #   #      our issue is that we need to change the mode to :kommand, and the
  #   #      instinct is to modify the graph here too - this is incorrect.
  #   #      API.CommandBuffer is a Scenic.Component responsible for managing it's
  #   #      own graph, so we have to forward on a msg to that component to
  #   #      make the change, but we can't actually do it here.

  #   # IO.puts "SHOW CMD BUF"
  #   # new_graph =
  #   #   state.graph
  #   #   |> Scenic.Graph.modify(:kommand_buffer, &update_opts(&1, hidden: false))
  #   #   #TODO find where we add this group to this levels' graph & give it an id
  #   #   # |> Scenic.Graph.modify(:kommand_buffer, fn x ->
  #   #   #       IO.puts "WE'RE DOING IT"
  #   #   # end)

  #   # Flamelex.GUI.RootScene.redraw(new_graph)
  #   Flamelex.GUI.Component.CommandBuffer.show

  #   {:noreply, state}
  # end
