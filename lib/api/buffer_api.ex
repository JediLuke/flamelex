defmodule Flamelex.API.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.BufferManager
  #TODO write this up
  # alias Flamelex.Structs.BufRef #NOTE: this is a little confusing, but unavoidable - that we have a %BufRef{} struct, and `Buffer` module...


  @doc """
  List all the open buffers.
  """
  def list, do: GenServer.call(BufferManager, :list_buffers)


  @doc """
  Searches the open buffers and returns a single %BufRef{}, or raises.
  """
  #TODO put a bang if it raises - it should just return nil if it cant find it
  def find(search_term), do: GenServer.call(BufferManager, {:find_buffer, search_term})


  @doc """
  Load some data into a new buffer. By default, we open a TextBuffer to
  open a file, given by the first parameter.

  ## Examples

  iex> Buffer.load("README.md")
  {:ok, %BufRef{} = _bufr_ref}
  """

  def open!, do: open!("/Users/luke/workbench/elixir/flamelex/README.md")

  def open!(filepath) do
    Flamelex.Fluxus.fire_action({
      :open_buffer,
        {:local_text_file, path: filepath}, %{
          label: filepath,
      }})
  end





  # def load(:text, data, opts) when is_map(opts) do
  #   Flamelex.FluxusRadix.handle_action({:open_buffer,
  #     opts |> Map.merge(%{ type: :text, data: data })
  #   })
  # end



  @doc """
  Return the contents of a buffer.
  """
  def read(%BufRef{} = buf) do
    ProcessRegistry.find!(buf) |> GenServer.call(:read)
  end




  @doc """
  Make modifications or edits, to a buffer. e.g.

  ```
  insertion_op  = {:insert, "Luke is the best!", 12}
  {:ok, b}      = Buffer.find("my_buffer")

  Buffer.modify(b, insertion_op)
  ```
  """
  # def modify(:active_buffer, modification) do
  #   PubSub.broadcast(topic: :active_buffer,
  #                    msg: {:active_buffer, :modification, modification})
  # end
  # def modify(buf, modification) do
  #   IO.puts "IHIHIH #{inspect buf}"
  #   #TODO make this a try/catch?
  #   ProcessRegistry.find!(buf) |> IO.inspect() |> GenServer.call({:modify, modification})
  # end



  def save(pid) when is_pid(pid) do
    pid |> GenServer.call(:save)
  end
  def save({:buffer, _id} = lookup_key) do
    ProcessRegistry.find!(lookup_key)
    |> GenServer.call(:save)
  end
  def save(buf) do
    save({:buffer, buf})
  end



  def close(buf) do
    Flamelex.Fluxus.fire_action({:close_buffer, buf})
  end

  def close_all! do
    raise "this should work, but is it too dangerous??"
    list()
    |> Enum.each(&Flamelex.Fluxus.fire_action({:close_buffer, &1}))
  end
end
