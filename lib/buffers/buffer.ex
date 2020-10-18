defmodule Flamelex.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.BufferManager
  alias Flamelex.Utilities.ProcessRegistry



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

    request_mgr =
      BufferManager.open_buffer(%{
        type: :text,
        from_file: filepath,
        open_in_gui?: true
      })

    case request_mgr do
      {:ok, name} ->
        name
      {:error, {:already_started, pid}} ->
        raise "Here we should just link to the alrdy open pid"
    end
  end



  @doc """
  Return the contents of a buffer.
  """
  def read(pid) when is_pid(pid) do
    pid
    |> GenServer.call(:read_contents)
  end
  def read({:buffer, _name} = buffer) do
    {:ok, pid} = ProcessRegistry.find(buffer)
    pid |> read()
  end
  def read({:error, reason}) do
    #NOTE: this can be matched if ProcessRegistry fails...
    {:error, reason}
  end
  def read(buf_name) do
    ProcessRegistry.find({:buffer, buf_name})
    |> read()
  end



  def modify(pid, modification) when is_pid(pid) do
    pid
    |> GenServer.call({:modify, modification})
  end
  def modify({:buffer, _name} = buffer, modification) do
    {:ok, pid} = ProcessRegistry.find(buffer)
    pid |> modify(modification)
  end
  def modify({:error, reason}, _modification) do
    #NOTE: this can be matched if ProcessRegistry fails...
    {:error, reason}
  end
  def modify(buf_name, modification) do
    ProcessRegistry.find({:buffer, buf_name})
    |> read()
  end



  def save(buf) do
    case ProcessRegistry.find_buffer(buf) do
      {:ok,       pid} -> pid |> GenServer.call(:save)
      {:error, reason} -> {:error, reason}
    end
  end


  def close(buf) do
    BufferManager.close_buffer(buf)
  end
end
