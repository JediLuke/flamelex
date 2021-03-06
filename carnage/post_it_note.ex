# defmodule GUI.Component.Note do
#   @moduledoc false
#   use Scenic.Component
#   alias Scenic.Graph
#   import Scenic.Primitives
#   require Logger
#   # import Utilities.ComponentUtils

#   @ibm_plex_mono Flamelex.GUI.Initialize.ibm_plex_mono_hash

#   @title_font_size 48

#   @title_prompt "New note..."
#   @text_prompt "Press <TAB> to move to the text input area."

#   def verify(%{
#     id: _id,
#     top_left_corner: {_x, _y},
#     dimensions: {_w, _h},
#     contents: %{
#       title: _title,
#       text: _text
#     }
#   } = data), do: {:ok, data}
#   def verify(_), do: :invalid_data

#   def info(_data), do: ~s(Invalid data)

#   def move_cursor_to_text_section(pid) do
#     GenServer.cast(pid, {:action, 'MOVE_CURSOR_TO_TEXT_SECTION'})
#   end

#   def move_cursor_to_title_section(pid) do
#     GenServer.cast(pid, {:action, 'MOVE_CURSOR_TO_TITLE_SECTION'})
#   end

#   def append_text(pid, :title, state) do
#     GenServer.cast(pid, {'APPEND_INPUT_TO_TITLE', state})
#   end

#   def append_text(pid, :text, state) do
#     GenServer.cast(pid, {'APPEND_INPUT_TO_TEXT', state})
#   end

#   def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
#     Process.monitor(pid)

#     new_component = {identifier, pid}
#     #TODO ensure new component registry is unique!
#     Logger.info "#{__MODULE__} registering component: #{inspect new_component}..."
#     new_ref_list = ref_list ++ [new_component]
#     new_state = state |> Map.replace!(:component_ref, new_ref_list)

#     {:reply, :ok, {new_state, graph}}
#   end

#   def handle_call(:deactivate, {_pid, _ref}, {state, graph}) do
#     Logger.info "#{__MODULE__} deactivating..."
#     {:reply, :ok, {state, graph}}
#   end

#   @doc false
#   def init(%{
#     id: id,
#     top_left_corner: {x, y},
#     dimensions: {width, height},
#     contents: %{title: title, text: note_contents}
#   } = data, _opts) do
#     Logger.info "#{__MODULE__} initializing...#{inspect data}"
#     title_text = if title == "", do: @title_prompt, else: title
#     note_text = if note_contents == "", do: @text_prompt, else: title
#     title_font_size = 48

#     #TODO remove/hide cursor if focus leaves this window (or we go into command mode)
#     #TODO if note crashes, Root needs to monitor it & remove it from it's component refs - but it's being restarted???

#     graph =
#       Graph.build()
#       |> group(fn graph ->
#            graph
#            |> rect({width, height}, translate: {x, y}, fill: :cornflower_blue, stroke: {1, :ghost_white})
#            |> text(title_text,
#              id: :title,
#              font: @ibm_plex_mono,
#              translate: {x+15, y+title_font_size}, # text draws from bottom-left corner?? :( also, how high is it???
#              font_size: title_font_size,
#              fill: :black)
#            |> add_cursor(data, title_font_size)
#            |> line({{x+15, y+title_font_size+25}, {x+width-15, y+title_font_size+25}}, stroke: {3, :black})
#            |> text(note_text,
#              id: :text,
#              font: @ibm_plex_mono,
#              translate: {x+15, y+title_font_size+65}, # text draws from bottom-left corner?? :( also, how high is it???
#              fill: :black)
#          end)

#     state = %{
#       component_ref: [],
#       title_origin: {x, y},
#       text_origin: {x+15, y+title_font_size+65}
#     }

#     GenServer.call(GUI.Scene.Root, {:register, id})
#     {:ok, {state, graph}, push: graph}
#   end

#   def handle_cast({'APPEND_INPUT_TO_TITLE', %{focus: :title, title: new_title}}, {state, graph}) do
#     new_graph =
#       graph |> Graph.modify(:title, &text(&1, new_title, fill: :black))

#     # find_component_reference_pid!(state.component_ref, :cursor)
#     # |> GUI.Component.Cursor.move_right_one_column()

#     {:noreply, {state, new_graph}, push: new_graph}
#   end

#   def handle_cast({'APPEND_INPUT_TO_TEXT', %{focus: :text, text: new_text}}, {state, graph}) do
#     new_graph =
#       graph |> Graph.modify(:text, &text(&1, new_text, fill: :black))

#     # find_component_reference_pid!(state.component_ref, :cursor)
#     # |> GUI.Component.Cursor.move_right_one_column()

#     {:noreply, {state, new_graph}, push: new_graph}
#   end

#   def handle_cast({:action, 'MOVE_CURSOR_TO_TEXT_SECTION'}, {state, graph}) do
#     {text_origin_x, text_origin_y} = state.text_origin
#     {new_x, new_y} = {text_origin_x, text_origin_y-15}
#     # get width of text font (use FontMetrics)
#     # get height of text font
#     text_size = 24 # I think? This is just what I set way back in Root scene

#     {_x_min, _y_min, _x_max, y_max} = GUI.Fonts.get_max_box_for_ibm_plex(text_size)
#     new_width        = GUI.Fonts.monospace_font_width(:ibm_plex, text_size)  #TODO should probably truncate this
#     y_box_buffer = 3
#     new_height       = y_max - y_box_buffer #TODO should probably truncate this

#     # find_component_reference_pid!(state.component_ref, :cursor)
#     # |> GUI.Component.Cursor.move(top_left_corner: {new_x, new_y}, dimensions: {new_width, new_height})

#     {:noreply, {state, graph}}
#   end

#   def handle_cast({:action, 'MOVE_CURSOR_TO_TITLE_SECTION'}, {state, graph}) do
#     # get width of text font (use FontMetrics)
#     # get height of text font

#     {_x_min, _y_min, _x_max, y_max} = GUI.Fonts.get_max_box_for_ibm_plex(@title_font_size)
#     new_width        = GUI.Fonts.monospace_font_width(:ibm_plex, @title_font_size)  #TODO should probably truncate this
#     y_box_buffer = 3
#     new_height       = y_max + y_box_buffer #TODO should probably truncate this

#     {x, y} = state.title_origin
#     y_offset     = y+10
#     y_box_buffer = 2 # it looks weird having box exact same size as the text
#     x_coordinate = x+15
#     y_coordinate = y_offset + y_box_buffer

#     # find_component_reference_pid!(state.component_ref, :cursor)
#     # |> GUI.Component.Cursor.move(top_left_corner: {x_coordinate, y_coordinate}, dimensions: {new_width, new_height})

#     {:noreply, {state, graph}}
#   end

#   defp add_cursor(graph, %{top_left_corner: {x, y}}, font_size) do
#     {_x_min, _y_min, _x_max, y_max} =
#       GUI.Fonts.get_max_box_for_ibm_plex(font_size)

#     y_offset     = y+10
#     y_box_buffer = 2 # it looks weird having box exact same size as the text
#     x_coordinate = x+15
#     y_coordinate = y_offset + y_box_buffer
#     width        = GUI.Fonts.monospace_font_width(:ibm_plex, font_size)  #TODO should probably truncate this
#     height       = y_max + y_box_buffer #TODO should probably truncate this

#     graph
#     |> GUI.Component.Cursor.add_to_graph(%{
#           id: :cursor,
#           top_left_corner: {x_coordinate, y_coordinate},
#           dimensions: {width, height},
#           parent: %{pid: self()}
#         })
#   end
# end

















# defmodule Franklin.Buffer.Note do
#   @moduledoc false
#   use GenServer
#   require Logger
#   alias Utilities.DataFile

#   def start_link(contents), do: GenServer.start_link(__MODULE__, contents)
#   def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
#   def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
#   def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
#   def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
#   def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)


#   ## GenServer callbacks
#   ## -------------------------------------------------------------------


#   def init(%{title: _title, text: _text} = contents) do
#     state = contents |> Map.merge(%{
#       uuid: UUID.uuid4(),
#       focus: :title
#     })

#     Logger.info "#{__MODULE__} initializing... #{inspect state}"
#     GUI.Scene.Root.action({'NEW_NOTE_COMMAND', contents, buffer_pid: self()})
#     {:ok, state}
#   end

#   def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :title} = state) do
#     state = %{state|title: state.title <> letter}
#     GUI.Component.Note.append_text(scenic_component_pid, :title, state)
#     {:noreply, state}
#   end

#   def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :text} = state) do
#     state = %{state|text: state.text <> letter}
#     GUI.Component.Note.append_text(scenic_component_pid, :text, state)
#     {:noreply, state}
#   end

#   def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
#     GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
#     new_state = %{state|focus: :text}
#     {:noreply, new_state}
#   end

#   def handle_cast(:save_and_close, state) do
#     DataFile.read()
#       |> Map.merge(%{
#            state.uuid => %{
#              title: state.title,
#              text: state.text,
#              datetime_utc: DateTime.utc_now(),
#              #TODO hash entire contents
#              #TODO handle timezones
#              tags: ["note"]
#            },
#          })
#       |> DataFile.write()

#     GUI.Scene.Root.action({:active_buffer, :note, 'CLOSE_NOTE_BUFFER'})
#     {:noreply, state}
#   end

#   def handle_cast(:tab_key_pressed, %{focus: :text} = state) do
#     Logger.warn "Text area doesn't handle tab character just yet..."
#     {:noreply, state}
#   end

#   def handle_cast(:reverse_tab, %{focus: :text} = state) do
#     Logger.warn "YES we got a shift+Tab in text though" #THIS WORKS!
#     GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'})
#     new_state = %{state|focus: :title}
#     {:noreply, new_state}
#   end
# end




# THIS WAS IN THE ORIGINAL CommandBuffer



#   describe "the command" do
#     test "`note` - creates a new note"
#     test "`restart` - restarts Franklin"
#     test "`help` - opens help", do: flunk "not yet implemented."
#     test "`reload GUI` - reloads the GUI"
#   end
