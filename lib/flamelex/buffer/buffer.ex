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

    open_buffer_result =
        BufferManager.open_buffer(%{
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
    BufferManager.open_buffer(%{
      type: :text,
      data: data
    } |> Map.merge(opts))
  end



  @doc """
  Return the contents of a buffer.
  """
  def read({:buffer, _id} = lookup_key) do
    IO.puts "READ 2"
    ProcessRegistry.find!(lookup_key)
    |> IO.inspect(label: "pid")
    |> GenServer.call(:read)
  end
  #NOTE: putting this first is a CLASSIC BLUNDER - infinite recursion
  def read(id) do
    IO.puts "READ 1"
    read({:buffer, id})
  end
  # def read(pid) when is_pid(pid) do
  #   pid

  # end
  # def read({:buffer, _name} = buffer) do
  #   {:ok, pid} = ProcessRegistry.find(buffer)
  #   pid |> read()
  # end
  # def read({:error, reason}) do
  #   #NOTE: this can be matched if ProcessRegistry fails...
  #   {:error, reason}
  # end
  # def read(buf_id) do
  #   IO.inspect buf_id, label: "LBF"
  #   ProcessRegistry.find({:buffer, buf_id})
  #   |> read()
  # end



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
