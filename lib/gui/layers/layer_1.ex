defmodule Flamelex.GUI.Layers.LayerOne do
   # NOTE: Something in here has to be about layouts
   # NOTE: Layer 1 is the primary app layer

   @behaviour Flamelex.GUI.Layer.Behaviour

   alias ScenicWidgets.Core.Utils.FlexiFrame

   @impl Flamelex.GUI.Layer.Behaviour

   def calc_state(%{root: %{layers: %{one: :split}}} = radix_state) do
      #TODO here, this is gonna get split msg when we call Flamelex.API.Editor.split

      %{framestack: [_menubar_f|editor_f]} =
      FlexiFrame.calc(
         radix_state.gui.viewport,
         {:standard_rule, linemark: radix_state.menu_bar.height}
      )

      frames = FlexiFrame.split(hd(editor_f))

      # Then we change the state of the layer to be showing 2 buffers, and we update the render function to render 2 buffers!!
      %{
         layer: :one,
         layout: :split,
         frames: frames,
         active_app: radix_state.root.active_app,
         active_buf: radix_state.editor.active_buf
      }
   end

   def calc_state(%{root: %{layers: %{one: %{explorer: %{active?: true}}}}} = radix_state) do

      main_pane =
         FlexiFrame.main_pane_frame(radix_state.gui.viewport, menu_bar_height: radix_state.menu_bar.height)

      [left_pane, right_pane] =
         # FlexiFrame.split(main_pane, horizontal: {32, :percent})
         FlexiFrame.split_horizontal(main_pane, 27)

      %{
         layer: :one,
         layout: %{
            explorer: left_pane,
            editor: right_pane
         },
         active_app: radix_state.root.active_app
      }
   end

   def calc_state(%{root: %{layers: %{one: %{layout: %{editor: :full_screen}}}}} = radix_state) do

      # calc the editor frame
      %{framestack: [_menubar_f|editor_f]} =
         FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      %{
         layer: :one,
         frame: hd(editor_f),
         active_app: radix_state.root.active_app,
         active_buf: radix_state.editor.active_buf
      }
   end

   def calc_state(radix_state) do
      dbg()
   end

   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{active_app: :desktop}, _radix_state) do
      {:ok, Scenic.Graph.build()}
   end

   def render(%{layout: :split, active_app: :editor, frames: [f1|f2]}, radix_state) do
      {:ok,
         Scenic.Graph.build()
         |> QuillEx.GUI.Components.Editor.add_to_graph(%{
            frame: f1,
            radix_state: radix_state,
            app: Flamelex
         })
         |> QuillEx.GUI.Components.Editor.add_to_graph(%{
            frame: hd(f2),
            radix_state: radix_state,
            app: Flamelex
         })
      }
   end

   def render(%{layout: %{
      explorer: explorer_frame,
      editor: editor_frame
   }, active_app: :editor}, radix_state) do
      IO.puts "DID WE GET HERERE?????"
      {:ok,
         Scenic.Graph.build()
         |> Scenic.Primitives.rect(explorer_frame.size, fill: :lime_green, translate: explorer_frame.pin)
         |> QuillEx.GUI.Components.Editor.add_to_graph(%{
            frame: editor_frame,
            radix_state: radix_state,
            app: Flamelex
         })
      }
   end

   def render(%{active_app: :editor, frame: frame}, radix_state) do
      {:ok,
         Scenic.Graph.build()
         |> QuillEx.GUI.Components.Editor.add_to_graph(%{
            frame: frame,
            radix_state: radix_state,
            app: Flamelex
         })
      }
   end

   def render(%{active_app: :memex, frame: frame}, radix_state) do
      {:ok,
         Scenic.Graph.build()
         |> Memelex.GUI.Components.MemDesk.add_to_graph(%{
            frame: frame,
            state: radix_state.memex,
            app: Flamelex
         })
      }
   end

end