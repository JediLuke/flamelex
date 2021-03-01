defmodule Flamelex.Buffer do
  @moduledoc """
  Flamelex.Buffer exposes the Buffer functionality.

  Users should never call this directly! Users go through APIs, which fire
  actions - and inside the reducers, that's where these functions will
  get called.
  """


  def open!(%{type: buffer_module} = params) when is_atom(buffer_module) do

    params = params
             |> add_this_process_to_callback_list()

    #TODO we could encapsulate this receive do messyness by implementing a DYnamixSupervisor for Buffers
    DynamicSupervisor.start_child(Flamelex.Buffer.Supervisor,
                                  {buffer_module, params})

    receive do
      {:ok_open_buffer, tag} ->
        tag
      anything_else ->
        raise "received unexpected callback: #{inspect anything_else}"
    after
      :timer.seconds(1) ->
        raise "Buffer failed to open. reason: TimedOut."
    end
  end

  #TODO
#   def show
#   def hide


      #TODO
      # @doc """
      # All Buffers support show/hide
      # """
      # @impl GenServer
      # def handle_cast(:show, buf) do
      #   Flamelex.GUI.Controller.action({:show, buf})
      #   {:noreply, buf}
      # end

      # def handle_cast(:hide, buf) do
      #   Flamelex.GUI.Controller.action({:hide, buf})
      #   {:noreply, buf}
      # end

  #TODO use TextCursor structs
#   def move_cursor(%BufRef{} = buf, %Cursor{num: 1}, %{to: destination}) do
#    #TODO call the pid, & give them the instructions

#   end



  defp add_this_process_to_callback_list(%{callback_list: l} = opts) when is_list(l) and length(l) >= 1 do
    Map.merge(opts, %{callback_list: l ++ [self()]}) # if we need to add to an existing list...
  end
  defp add_this_process_to_callback_list(opts) do
    Map.merge(opts, %{callback_list: [self()]}) # if we need to create the callback_list...
  end
end
