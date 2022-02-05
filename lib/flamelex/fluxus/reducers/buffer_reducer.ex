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

        new_editor_graph = Scenic.Graph.build()
        |> Flamelex.GUI.Editor.Layout.add_to_graph(%{
                frame: Frame.new(radix_state.gui.viewport, menubar_height: 60), #TODO get this value from somewhere better
                # state: radix_state.memex
            }, id: :editor)

        new_radix_state = radix_state
        |> put_in([:root, :active_app], :editor)
        |> put_in([:root, :layers, @app_layer], new_editor_graph)

        {:ok, new_radix_state}
    end

    def process(_radix_state, action) do
        Logger.debug "#{__MODULE__} ignoring: #{inspect action}"
        :ignore
    end

end
  