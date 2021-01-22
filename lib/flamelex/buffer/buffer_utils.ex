defmodule Flamelex.Buffer.BufUtils do
  alias Flamelex.Structs.Buf



  # #TODO here next !!!
  # def open_buffer(params) do
  #       #TODO - here is what we need:
  #   # 1) way of registering processes
  #   # 2) a system for doing that
  #   # 3) a PubSub which works, which goes heirarchically, and the top level can be some reference like "lukes_journal", so it's easy to broadcast to all processes which need updates about my journal
  #   case start_buffer_process(params) do
  #     {:ok, %Buf{} = buf} ->
  #         # num_buffers = Enum.count(state)
  #         if open_this_buffer_in_gui?(params) do
  #           :ok = Flamelex.GUI.Controller.show(buf.ref)
  #         end
  #         {:reply, {:ok, buf}, state ++ [buf]}
  #     {:error, reason} ->
  #         {:reply, {:error, reason}, state}
  #   end
  # end

    # we accept just raw_data and a ref as a valid text buffer - we don't discriminate!!
    # def open_buffer(%{type: :text, ref: _r, raw_data: _d} = params) do
    #   DynamicSupervisor.start_child(
    #                       Flamelex.Buffer.Supervisor,
    #                       {Flamelex.Buffer.Text, params})
    # end

    @file_open_timeout 3_000
    def open_buffer(%{type: :text, from_file: filepath} = params) do
      # opening from a text file has a bit of a handshake/callback thing going on...

      params =
        params |> Map.merge(%{
                        ref: {:file, filepath},       # this is how we construct a Buffer ref for a file on disk
                        after_boot_callback: self()   # add the callback, since we're going to read from disk...
                      })

      start_process_attempt =
        DynamicSupervisor.start_child(
                            Flamelex.Buffer.Supervisor,
                            {Flamelex.Buffer.Text, params})

      case start_process_attempt do
        {:ok, pid} ->
            wait_for_callback(pid, filepath)
        {:error, reason} ->
            {:error, reason}
        # {:error, {:function_clause, _details_list} = reason} ->
        #     IO.puts "FUNCTION CLAUSE ERROR"
        #     {:error, reason}
      end
    end




  defp wait_for_callback(pid, filepath) do
    #NOTE: We want the Text buffer to try to open the file (in that
    #      process!), but not inside the init/1 callback - because then
    #      if it fails to read the file, the init will fail... instead:
    receive do
      {^pid, :successfully_opened, ^filepath, %Buf{} = buf} ->
        {:ok, buf}
    after
      @file_open_timeout ->
        IO.puts "Didn't get a msg back from the recently opened buffer" #TODO make it red
        Process.exit(pid, :kill)
        {:error, "timed out waiting for the Buffer to open a file."}
    end
  end


  def open_this_buffer_in_gui?(%{open_in_gui?: open?}), do: open?
  def open_this_buffer_in_gui?(_else), do: false


end
