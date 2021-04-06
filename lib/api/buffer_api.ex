defmodule Flamelex.API.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  use Flamelex.ProjectAliases
  alias Flamelex.BufferManager


  @doc """
  List all the open buffers.
  """
  def list do
    %{buffer_list: buffer_list} = GenServer.call(BufferManager, :get_state)
    #TODO we ought to trigger a GUI update here - possibly, this should indeed reside in BufferManager... since then at least GUI updates wiull be in sync
    buffer_list
  end


  @doc """
  Return the active Buffer.
  """
  def active_buffer do
    %{active_buffer: active_buffer} = GenServer.call(BufferManager, :get_state)
    active_buffer
  end


  # @doc """
  # Searches the open buffers and returns a single %BufRef{}, or raises.
  # """
  # #TODO put a bang if it raises - it should just return nil if it cant find it
  # def find(search_term) do
  #   GenServer.call(BufferManager, {:find_buffer, search_term})
  # end


  @doc """
  Load some data into a new buffer. By default, we open a TextBuffer to
  open a file, given by the first parameter.

  ## Examples

  iex> Buffer.open!("README.md")
  {:buffer, {:file, "README.md"}}
  """

  #TODO make this open a new blank buffer
  def open!, do: open!(File.cwd! <> "/README.md") #NOTE: this only works from the root directory of the Flamelex project...

  def open!(filepath) do

    GenServer.cast(Flamelex.FluxusRadix, {:action, {
        :open_buffer, %{
            type: Flamelex.Buffer.Text,
            source: {:file, filepath},
            label: filepath,
            open_in_gui?: true, #TODO set active buffer
            callback_list: [self()]
    }}})

    # await callback...
    receive do
      {:ok_open_buffer, tag} ->
        tag
    after
      :timer.seconds(1) ->
        raise "Buffer failed to open. reason: TimedOut."
    end

    #TODO I don't actually know what I like better, the above, or the below...

    # Flamalex.Fluxus.fire(:action, {
    #     :open_buffer, %{
    #         type: Flamelex.Buffer.Text,
    #         source: {:file, filepath},
    #         label: filepath,
    #         open_in_gui?: true, #TODO set active buffer
    #         callback_list: [self()]
    #         }},
    #     expect_callback?: {true, :ok_open_buffer}
    # })

  end


  @doc """
  Return the contents of a buffer.
  """
  def read(buf) do
    ProcessRegistry.find!(buf) |> GenServer.call(:read)
  end


  @doc """
  Make modifications or edits, to a buffer. e.g.

  ```
  insertion_op  = {:insert, "Luke is the best!", 12}
  {:ok, b}      = Buffer.find("my_buffer") #TODO still correct?

  Buffer.modify(b, insertion_op)
  ```
  """
  def modify(buf, modification) do
    GenServer.cast(Flamelex.FluxusRadix, {:action, {
        :modify_buffer, %{
            buffer: buf,
            details: modification
        }
    }})
  end


  @doc """
  Tell a buffer to save it's contents.
  """
  def save({:buffer, _details} = buf) do
    ProcessRegistry.find!(buf) |> GenServer.call(:save)
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


  def close(buf) do
    #TODO this is causing GUI controller & VimServer to also restart??
    Flamelex.Fluxus.fire_action({:close_buffer, buf})
  end

  def close_all! do
    raise "this should work, but is it too dangerous??"
    list()
    |> Enum.each(&Flamelex.Fluxus.fire_action({:close_buffer, &1}))
  end
end
