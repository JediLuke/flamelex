defmodule Flamelex.API.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.BufferManager



  @doc """
  List all the open buffers.
  """
  def list, do: BufferManager.list_open_buffers()



  @doc """
  Load some data into a new buffer. By default, we open a TextBuffer to
  open a file, given by the first parameter.

  ## Examples

    iex> Buffer.load("README.md")
    {:ok, _pid} #TODO return the name/identifier instead, otherwise return pid

  """
  def open!, do: open! "/Users/luke/workbench/elixir/flamelex/README.md"

  def open!(filepath) do
    Logger.info "Loading new text buffer for file: #{inspect filepath}..."

    open_buffer_result =
        Flamelex.OmegaMaster.open_buffer(%{
          type: :text,
          from_file: filepath,
          open_in_gui?: true
        })

    case open_buffer_result do
      {:ok, name} ->
        name
      {:error, {:already_started, _pid}} ->
        raise "Here we should just link to the alrdy open pid"
    end
  end


  def load(:text, data, opts) when is_map(opts) do
    Flamelex.OmegaMaster.open_buffer(%{
      type: :text,
      data: data
    } |> Map.merge(opts))
  end



  @doc """
  Return the contents of a buffer.
  """
  def read(pid) when is_pid(pid) do
    pid |> GenServer.call(:read)
  end
  def read({:buffer, _id} = lookup_key) do
    ProcessRegistry.find!(lookup_key)
    |> GenServer.call(:read)
  end
  #NOTE: putting this first is a CLASSIC BLUNDER - infinite recursion
  def read(id) do
    read({:buffer, id})
  end



  def modify(pid, modification) when is_pid(pid) do
    pid
    |> GenServer.call({:modify, modification})
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
