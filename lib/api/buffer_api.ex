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
    Flamelex.OmegaMaster.action({:open_buffer,
      opts |> Map.merge(%{ type: :text, data: data })
    })
  end



  @doc """
  Return the contents of a buffer.
  """
  def read(%Buf{} = buf) do
    ProcessRegistry.find!(buf) |> GenServer.call(:read)
  end



  #TODO these should be Buffers
  def modify(pid, modification) when is_pid(pid) do
    pid |> GenServer.call({:modify, modification})
  end
  def modify({:buffer, _id} = lookup_key, modification) do
    ProcessRegistry.find!(lookup_key)
    |> GenServer.call({:modify, modification})
  end
  def modify(id, modification) do
    modify({:buffer, id}, modification)
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
