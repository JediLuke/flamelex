defmodule Flamelex.API.Buffer do
   @moduledoc """
   The interface to all the Buffer commands.
   """
   use Flamelex.Lib.ProjectAliases
   alias Flamelex.BufferManager
   alias QuillEx.Reducers.BufferReducer, as: QuillExBufrReducer # NOTE: We use the QuillEx QuillExBufrReducer...
   alias Flamelex.Fluxus.RadixStore

   @doc """
   List all the open buffers.
   """
   def list do
      RadixStore.get().editor.buffers
   end

   def new do
      new("")
   end

   def new(data) when is_bitstring(data) do
      {:ok, radix_state} = Flamelex.Fluxus.declare({QuillExBufrReducer, {:open_buffer, %{data: data, mode: {:vim, :normal}}}})
      radix_state.editor.active_buf
   end

  @doc """
  Open a file and load the contents into a buffer.

  This function differs from `new/1` mainly in that it takes in a _filename_
  as it's param, not the data itself.

  ## Examples

  iex> Buffer.open("README.md")
  {:buffer, {:file, "README.md"}}
  """
  
  #TODO THIS NEEDS TO CHECK IF THE buffer is already open or not
  def open(filename) when is_bitstring(filename) do
    {:ok, radix_state} = Flamelex.Fluxus.declare({QuillExBufrReducer, {:open_buffer, %{file: filename, mode: {:vim, :normal}}}})
    radix_state.editor.active_buf
  end

  # this is just for convenience
  def open({:buffer, _id} = buf), do: switch(buf)

  @doc """
  Return the active Buffer.
  """
  def active, do: active_buf()

  def active_buf do
    RadixStore.get().editor.active_buf
  end

  def switch({:buffer, _id} = buf) do
    Flamelex.Fluxus.action({QuillExBufrReducer, {:activate, buf}})
  end

  def switch(%{id: {:buffer, _id} = buf}) do
    switch(buf)
  end

  def switch(n) when n >= 1 do
    RadixStore.get().editor.buffers
    |> Enum.at(n-1)
    |> switch()
  end

  # @doc """
  # Searches the open buffers and returns a single Buffer.id
  # """
  def find(search_term) do
    raise "Nop"
    # {:ok, res} = GenServer.call(BufferManager, {:find_buffer, search_term})
    # res
  end

  @doc """
  Searches the open buffers, but raises an error if it can't find any Buffer
  like the search_term.
  """
  def find!(search_term) do
    raise "Nop"
    # case GenServer.call(BufferManager, {:find_buffer, search_term}) do
    #   {:ok, nil} ->
    #     raise "Could not find any Buffer related to: #{inspect search_term}"
    #   {:ok, res} ->
    #     res
    # end
  end


  @doc """
  Return the contents of a buffer.
  """
  def read(buf) do
    [buf] = list() |> Enum.filter(&(&1.id == buf))
    buf.data
  end


  @doc """
  Make modifications or edits, to a buffer. e.g.

  ```
  insertion_op  = {:insert, "Luke is the best!", 12}
  {:ok, b}      = Buffer.find("my_buffer") #TODO still correct?

  Buffer.modify(b, insertion_op)
  ```
  """

  # does editing actions on a buffer
  def edit() do
    raise "do it"
  end

  def modify(%{id: buf_id}, modification) do
    modify(buf_id, modification)
  end

  def modify({:buffer, _buf_id} = buffer, modification) do
    Flamelex.Fluxus.action({QuillExBufrReducer, {:modify_buf, buffer, modification}})
  end


   @doc """
   Scroll the buffer around.
   """
   def scroll({_x_scroll, _y_scroll} = scroll_delta) do
      Flamelex.Fluxus.action({QuillExBufrReducer, {:scroll, :active_buf, {:delta, scroll_delta}}})
   end

  @doc """
  Scroll the buffer around.
  """
  @absolute_positions [:first_line, :last_line]
  def move_cursor(absolute) when absolute in @absolute_positions do
    Flamelex.Fluxus.action({QuillExBufrReducer, {:move_cursor, :active_buf, absolute}})
  end

  def move_cursor({_column_delta, _line_delta} = cursor_move_delta) do
    Flamelex.Fluxus.action({QuillExBufrReducer, {:move_cursor, {:delta, cursor_move_delta}}})
  end

  @doc """
  Tell a buffer to save it's contents.
  """
  def save do
    save(active_buf())
  end

  def save({:buffer, _details} = buf) do
    Flamelex.Fluxus.action({QuillExBufrReducer, {:save, buf}})
  end


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

  def close do
    active() |> close()
  end

  def close(buf) do
    #TODO this is causing GUI controller & VimServer to also restart??
    Flamelex.Fluxus.action({QuillExBufrReducer, {:close_buffer, buf}})
  end

  def close_all! do
    # raise "this should work, but is it too dangerous??"
    list() |> Enum.each(&close(&1))
  end

end








# def handle_call({:find_buffer, search_term}, _from, state) do

#   #TODO move to a pure function, under a Task.Supervisor
#   similarity_cutoff = 0.72 # used to compare how similar the strings are

#   find_buf =
#     state
#     |> Enum.find(
#          :no_matching_buffer_found, # this is the default value we return if no element is found by the function below
#          fn b ->
#            # TheFuzz.compare(:jaro_winkler, search_term, b.label) >= similarity_cutoff
#            String.jaro_distance(search_term, b.label) >= similarity_cutoff
#          end)

#   case find_buf do
#     :no_matching_buffer_found ->
#       {:reply, {:error, "no matching buffer found"}, state}
#     buf ->
#       {:reply, {:ok, buf}, state}
#   end
# end

# def handle_call(:save_active_buffer, _from, state) do
#   results = state.active_buffer
#             |> ProcessRegistry.find!()
#             |> GenServer.call(:save)

#   {:reply, results, state}
# end


# def handle_call(:count_buffers, _from, state) do
#   count = Enum.count(state)
#   {:reply, count, state}
# end