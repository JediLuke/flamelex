defmodule Flamelex.API.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.BufferManager
  alias Flamelex.Structs.Buf #NOTE: this is a little confusing, but unavoidable - that we have a %Buf{} struct, and `Buffer` module...



  @doc """
  List all the open buffers.
  """
  def list, do: GenServer.call(BufferManager, :list_buffers)


  @doc """
  Searches the open buffers and returns a single %Buf{}, or raises.
  """
  def find(search_term), do: GenServer.call(BufferManager, {:find_buffer, search_term})

  @doc """
  Load some data into a new buffer. By default, we open a TextBuffer to
  open a file, given by the first parameter.

  ## Examples

  iex> Buffer.load("README.md")
  {:ok, %Buf{} = _bufr_ref}
  """
  def open!, do: open! "/Users/luke/workbench/elixir/flamelex/README.md"

  def open!(filepath, params \\ %{}) do
    IO.puts "Loading new text buffer for file: #{inspect filepath}..."

    case GenServer.call(BufferManager, {:open_buffer, %{
           type: :text,
           label: "journal - today",
           from_file: filepath,
           open_in_gui?: true,
    } |> Map.merge(params)}) do
         {:ok, %Buf{} = buf} ->
            buf
         {:error, {:already_started, _pid}} ->
            raise "Here we should just link to the alrdy open pid"
         {:error, reason} ->
            raise "dunno lol - #{inspect reason}"
    end
  end



  def load(:text, data, opts) when is_map(opts) do
    Flamelex.FluxusRadix.action({:open_buffer,
      opts |> Map.merge(%{ type: :text, data: data })
    })
  end



  @doc """
  Return the contents of a buffer.
  """
  def read(%Buf{} = buf) do
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
  def modify(:active_buffer, modification) do
    PubSub.broadcast(topic: :active_buffer,
                     msg: {:active_buffer, :modification, modification})
  end
  def modify(buf, modification) do
    IO.puts "IHIHIH #{inspect buf}"
    #TODO make this a try/catch?
    ProcessRegistry.find!(buf) |> IO.inspect() |> GenServer.call({:modify, modification})
  end



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
    BufferManager.close_buffer(buf)
  end
end
