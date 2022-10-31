defmodule Flamelex.Fluxus.Reducers.Buffer do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger

   # @app_layer :one

   def process(radix_state, action) do
      # NOTE - basically we get QuillEx to do everything for us...
      QuillEx.Reducers.BufferReducer.process(radix_state, action)
   end

end



    # def process((%{editor: %{buffers: buf_list}} = radix_state, {:open_buffer, %{name: name, data: text}}) do
    #     new_radix_state = radix_state
    #     |> put_in([:root, :active_app], :desktop)
    #     |> put_in([:root, :layers, @app_layer], desktop_graph)

    #     {:ok, new_radix_state}
    # end

    # def process(%{editor: %{buffers: buf_list}} = radix_state, {:open_buffer, %{data: text} = new_buf})
    #     when is_bitstring(text) do

    #         num_buffers = Enum.count(buf_list)
    #         new_buf = Buffer.new(%{id: {:buffer, "untitled_" <> Integer.to_string(num_buffers + 1) <> ".txt*"}, type: :text})

    #         new_radix_state = radix_state
    #             |> put_in([:editor, :buffers], buf_list ++ [new_buf])
    #             |> put_in([:editor, :active_buf], new_buf.id)

    #         {:ok, new_radix_state}
    # end





# defmodule Flamelex.Fluxus.Reducers.Buffer do
#     @moduledoc false
#     use Flamelex.ProjectAliases
#     require Logger
#     alias Flamelex.Fluxus.Reducers.Buffer.Modify
  
#     @app_layer :one

#     defguard is_valid_buf(name, text) when is_bitstring(name) and is_bitstring(text)

    
#     def process(%{editor: %{buffers: buf_list}} = radix_state, {:open_buffer, %{name: name, data: text}}) when is_valid_buf(name, text) do
#         #Logger.debug "opening new buffer..."

#         new_buf = ScenicWidgets.TextPad.Structs.Buffer.new(%{
#             id: {:buffer, "untitled*"},
#             type: :text,
#             data: text,
#             mode: {:vim, :normal},
#             dirty?: true
#         })

#         new_editor_graph = Scenic.Graph.build()
#         |> Flamelex.GUI.TextFile.Layout.add_to_graph(%{
#                 #TODO dont pass in menubar_height as a param to Frame :facepalm:
#                 buffer_id: new_buf.id,
#                 frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
#                 font: radix_state.gui.fonts.ibm_plex_mono,
#                 state: new_buf
#             }, id: new_buf.id)

#         new_radix_state = radix_state
#         |> put_in([:editor, :buffers], (if (is_nil(buf_list) or buf_list == []), do: [new_buf], else: buf_list ++ [new_buf]))
#         |> put_in([:editor, :active_buf], new_buf.id)
#         |> put_in([:root, :active_app], :editor) #TODO maybe don't put it all in RadixState, because then changes will be broadcast out everywhere... Maybe it's better to use BufferManager? Then again, maybe not...
#         |> put_in([:root, :layers, @app_layer], new_editor_graph)

#         {:ok, new_radix_state}
#     end

#     def process(%{editor: %{buffers: buf_list}} = radix_state, {:open_buffer, %{data: text}}) when is_bitstring(text) do
#         new_buf_name = new_untitled_buf_name(buf_list)
#         process(radix_state, {:open_buffer, %{name: new_buf_name, data: text}})
#     end

#     def process(radix_state, {:open_buffer, %{file: filename}}) when is_bitstring(filename) do
#         Logger.debug "Opening file: #{inspect filename}..."
#         text = File.read!(filename)
#         process(radix_state, {:open_buffer, %{name: filename, data: text}})
#     end

#     def process(%{editor: %{buffers: []}} = radix_state, {:modify_buf, _buf_id, _modification} = action) do
#         raise "Received :modify_buf action, but there are no open buffers. Action: #{inspect action}"    
#     end

#     def process(%{editor: %{buffers: []}}, {:close_buffer, buffer}) do
#         Logger.warn "Tried closing a buffer `#{inspect buffer}` but none are open."
#         :ignore
#     end

#     def process(%{editor: %{buffers: buf_list}} = radix_state, {:close_buffer, buffer}) do
#         new_buf_list = buf_list |> Enum.reject(& &1.id == buffer)

#         new_radix_state =
#             if new_buf_list == [] do
#                 Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Desktop, :show_desktop})

#                 radix_state
#                 |> put_in([:editor, :buffers], new_buf_list)
#                 |> put_in([:editor, :active_buf], nil)
#                 |> put_in([:root, :active_app], :desktop)
#             else
#                 radix_state
#                 |> put_in([:editor, :buffers], new_buf_list)
#                 |> put_in([:editor, :active_buf], hd(new_buf_list))
#             end
    
#         {:ok, new_radix_state}
#     end

#     def process(%{editor: %{active_buf: buf_id}} = radix_state, {:modify_buf, buf_id, mod}) do #NOTE: `buf_id` has to be the same in both places for this clause to match
#         new_radix_state = radix_state
#         |> Modify.modify(buf_id, mod)

#         {:ok, new_radix_state}
#     end



# #   # to move a cursor, we just forward the message on to the specific buffer
# #   def async_reduce(%{action: {:move_cursor, specifics}}) do
# #     %{buffer: buffer, details: details} = specifics

# #     ProcessRegistry.find!(buffer)
# #     |> GenServer.cast({:move_cursor, details})
# #   end

# #   def async_reduce(%{action: {:activate, _buf} = action}) do
# #     Logger.debug "#{__MODULE__} recv'd: #{inspect action}"
# #     ## Find the buffer, set it to active
# #     # ProcessRegistry.find!(buffer)

# #     ## Update the GUI - note: this is what we DONT WANT (maybe??) - we want to calc a new state & pass it in to a "render" GUI function, not fire off side-effects like this!
# #         # state + action -> state |> fn (RadixState) -> render_gui()
# #         # the inherent problem with this is that state in ELixir is broken up into different processes!!
# #     # :ok = GenServer.call(GUIController, action)
# #     raise "unable to process action #{inspect action}"
# #   end
