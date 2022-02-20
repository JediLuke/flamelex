defmodule Flamelex.Fluxus.Reducers.Buffer do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  
    @app_layer :one

    def process(%{root: %{active_app: :desktop}, editor: %{active_buf: nil, buffers: []}} = radix_state, {:open_buffer, %{data: data}}) do
        IO.inspect radix_state
        #TODO we need to add a new buffer here

        # update layer 2, with new graph, new active app, add buffer data in aswell
        # Logger.debug "swapping from `#{inspect active_app}` to `:memex` (with history)..."

        # new_radix_state = radix_state
        # |> put_in([:root, :active_app], :memex)
        # |> put_in([:root, :layers, @app_layer], stashed_memex_graph)

        # {:ok, new_radix_state}

        #FOR each buffer, spin up a new component

        new_editor_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Editor.Layout.add_to_graph(%{
                frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
                font: radix_state.gui.fonts.ibm_plex_mono
                # state: radix_state.memex
            }, id: :editor)

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :editor)
        |> put_in([:root, :layers, @app_layer], new_editor_graph)

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

#   def async_reduce(%{action: {:close_buffer, buffer}}) do
#     GenServer.cast(Flamelex.BufferManager, {:close, buffer})
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

  