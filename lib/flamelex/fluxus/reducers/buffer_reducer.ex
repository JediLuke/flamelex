defmodule Flamelex.Fluxus.Reducers.Buffer do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  
    @app_layer :one

    # Open a new buffer, when we have no buffers already open, just by accepting some text
    def process(%{editor: %{active_buf: nil, buffers: []}} = radix_state, {:open_buffer, %{data: text}}) when is_bitstring(text) do
        #Logger.debug "opening new buffer..."

        # %Buffer{
        #             # rego_tag:
        #             type: Flamelex.Buffer.Text,
        #             source: {:file, filepath},
        #             label: filepath,
        #             mode: :normal,
        #             open_in_gui?: true, #TODO set active buffer
        #             callback_list: [self()]
        #             data: file_contents,    # the raw data
        #             unsaved_changes?: nil,  # a flag to say if we have unsaved changes
        #             time_opened #TODO
        #             cursors: [%{line: 1, col: 1}],
        #             lines: file_contents |> TextBufferUtils.parse_raw_text_into_lines(),
        #             gui_data: %{
        #             component_rego: ,
        # }

        new_buffer = %{ #TODO buffer struct?
            id: {:buffer, "untitled"},
            type: :text,
            source: nil,
            label: nil,
            data: text,
            mode: {:vim, :normal},
            unsaved_changes?: false,
            cursors: [%{line: 1, col: 1}]
        }

        new_editor_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Editor.Layout.add_to_graph(%{
                #TODO dont pass in menubar_height as a param to Frame :facepalm:
                buffer_id: new_buffer.id,
                frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
                font: radix_state.fonts.ibm_plex_mono,
                state: new_buffer
            }, id: new_buffer.id)

        new_radix_state = radix_state
        |> put_in([:editor, :buffers], [new_buffer |> Map.merge(%{graph: new_editor_graph})])
        |> put_in([:editor, :active_buf], new_buffer.id)
        |> put_in([:root, :active_app], :editor) #TODO maybe don't put it all in RadixState, because then changes will be broadcast out everywhere...
        |> put_in([:root, :layers, @app_layer], new_editor_graph)

        {:ok, new_radix_state}
    end



    def process(%{editor: %{buffers: []}} = radix_state, {:modify_buf, _buf_id, _modification} = action) do
        raise "Received :modify_buf action, but there are no open buffers. Action: #{inspect action}"    
    end

    def process(%{editor: %{buffers: []}}, {:close_buffer, buffer}) do
        Logger.warn "Tried closing a buffer `#{inspect buffer}` but none are open."
        :ignore
    end

    def process(%{editor: %{buffers: buf_list}} = radix_state, {:close_buffer, buffer}) do
        new_buf_list = buf_list |> Enum.reject(& &1.id == buffer)

        new_radix_state = radix_state
        |> put_in([:editor, :buffers], new_buf_list)
        |> put_in([:editor, :active_buf], nil)

        {:ok, new_radix_state}
    end

    def process(%{editor: %{buffers: buffers}} = radix_state, {:modify_buf, buf_id, {:set_mode, m}}) do
        # buf = buffers |> Enum.find(& &1.id == buf_id)
        # new_buf = buf |> Map.merge(%{mode: m})

        IO.puts "SETTING MODE #{inspect buf_id} to #{inspect m}"
    
        new_buffers = buffers |> Enum.map(fn
          %{id: ^buf_id} = old_buf ->

            new_editor_graph = Scenic.Graph.build()
            |> Flamelex.GUI.Editor.Layout.add_to_graph(%{
                    #TODO dont pass in menubar_height as a param to Frame :facepalm:
                    buffer_id: old_buf.id,
                    frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
                    font: radix_state.fonts.ibm_plex_mono,
                    state: old_buf |> Map.merge(%{mode: m})
                }, id: old_buf.id)

            old_buf |> Map.merge(%{
                mode: m,
                graph: new_editor_graph
            })

          other_buf ->
              other_buf
        end)

        new_radix_state = radix_state
        |> put_in([:editor, :buffers], new_buffers)

        {:ok, new_radix_state}
    end

end



# defmodule Flamelex.Fluxus.Reducers.Buffer do #TODO rename module
#   require Logger


#   def handle(params) do
#     # spin up a new process to do the handling...
#     Task.Supervisor.start_child(
#         Flamelex.Buffer.Reducer.TaskSupervisor,
#             __MODULE__,
#             :async_reduce,  # call the `async_reduce` function, defined below
#             [params]        # and pass it the params
#       )
#   end


#   def async_reduce(%{action: {:open_buffer, opts}} = params) do

#     # step 1 - open the buffer
#     buf = Flamelex.Buffer.open!(opts)

#     # step 2 - update FluxusRadix (because we forced a root-level update)
#     radix_update =
#       {:radix_state_update, params.radix_state
#                             |> RadixState.set_active_buffer(buf)}

#     GenServer.cast(Flamelex.FluxusRadix, radix_update)

#     # Flamelex.API.Mode.switch_mode(:insert)

#   end

#   # to move a cursor, we just forward the message on to the specific buffer
#   def async_reduce(%{action: {:move_cursor, specifics}}) do
#     %{buffer: buffer, details: details} = specifics

#     ProcessRegistry.find!(buffer)
#     |> GenServer.cast({:move_cursor, details})
#   end

#   def async_reduce(%{action: {:activate, _buf} = action}) do
#     Logger.debug "#{__MODULE__} recv'd: #{inspect action}"
#     ## Find the buffer, set it to active
#     # ProcessRegistry.find!(buffer)

#     ## Update the GUI - note: this is what we DONT WANT (maybe??) - we want to calc a new state & pass it in to a "render" GUI function, not fire off side-effects like this!
#         # state + action -> state |> fn (RadixState) -> render_gui()
#         # the inherent problem with this is that state in ELixir is broken up into different processes!!
#     # :ok = GenServer.call(GUIController, action)
#     raise "unable to process action #{inspect action}"
    
#     ## 
#   end

#   # modifying buffers...
#   def async_reduce(%{action: {:modify_buffer, specifics}}) do
#     %{buffer: buffer, details: details} = specifics

#     ProcessRegistry.find!(buffer)
#     |> GenServer.call({:modify, details})

#     #TODO update GUI here
#   end




#   # below here are the pattern match functions to handle actions we
#   # receive but we want to ignore


#   def async_reduce(%{action: name}) do
#     Logger.warn "#{__MODULE__} ignoring an action... #{inspect name}"
#     :ignoring_action
#   end

#   def async_reduce(unmatched_action) do
#     Logger.warn "#{__MODULE__} ignoring an action... #{inspect unmatched_action}"
#     :ignoring_action
#   end
# end

  