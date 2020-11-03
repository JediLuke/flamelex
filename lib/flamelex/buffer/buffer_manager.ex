
defmodule Flamelex.BufferManager do
  @moduledoc """
  Coordinates & administrates all the open buffers.
  """
  use GenServer
  use Flamelex.ProjectAliases
  require Logger

  #TODO if a buffer crashes, need to catch it & alert GUI.Controller
  #TODO idea: the GUI should turn grey, with an x through it - but it has memory (text etc) in it - maybe it can be used to recover the Buffer state...


  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @doc """
  The *correct* way to open a new buffer.
  """
  def open_buffer(params) do
    GenServer.call(__MODULE__, {:open_buffer, params})
  end

  def count_open_buffers do
    GenServer.call(__MODULE__, :count_buffers)
  end

  def list_open_buffers do
    GenServer.call(__MODULE__, :list_buffers)
  end

  def close_buffer(buf) do
    GenServer.call(__MODULE__, {:close_buffer, buf})
  end


  ## GenServer callbacks
  ## -------------------


  def init(_params) do
    IO.puts "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, _initial_state = []}
  end


  def handle_call({:open_buffer, %{
        type: :text, data: data, name: name } = params
        }, _from, state) when is_bitstring(data) do

    case start_buffer_process(params) do
      {:ok, _pid} ->
        {:reply, {:ok, name}, state ++ [name]} #TODO do we just store a list of buffer names? What about numbers? order??
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:open_buffer, %{
    type: :text,
    from_file: filepath
  } = params}, _from, state) do
    case really_open_buffer(params) do
      {:ok, new_buf} ->
        {:reply, {:ok, new_buf}, state ++ [new_buf]}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  #NOTE: no `name` param
  def handle_call({:open_buffer, %{type: :text} = params}, from, state) do
    Logger.warn "Opening a buffer without a name..."
    new_params = params |> Map.merge(%{name: "unnamed-buf"})
    handle_call({:open_buffer, new_params}, from, state)
  end

  def handle_call(:count_buffers, _from, state) do
    count = Enum.count(state)
    {:reply, count, state}
  end

  def handle_call(:list_buffers, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:close_buffer, buf}, _from, state) do
    if state |> Enum.member?(buf) do
      case ProcessRegistry.find_buffer(buf) do
        {:ok, pid} ->
          pid |> GenServer.cast(:close)
          new_state = state |> Enum.reject(& &1 == buf)
          {:reply, :ok, new_state}
        {:error, reason} ->
          {:reply, {:error, "not an open buffer: " <> reason}, state}
      end
    else
      {:reply, {:error, "not an open buffer"}, state}
    end
  end


  @file_open_timeout 3_000
  def really_open_buffer(%{
    type: :text,
    from_file: filepath
  }) do

    start_process_attempt =
      DynamicSupervisor.start_child(
        Flamelex.Buffer.Supervisor,
          {Buffer.Text, %{
            from_file: filepath,
            after_boot_callback: self()
          }})

    case start_process_attempt do
      {:ok, pid} ->
            #NOTE: We want the Text buffer to try to open the file (in that
            #      process!), but not inside the init/1 callback - because then
            #      if it fails to read the file, the init will fail... instead
            receive do
              {^pid, :successfully_opened, ^filepath, buf_name} ->
                {:ok, buf_name}
            after
              @file_open_timeout ->
                Logger.error "Didn't get a msg back from the recently opened buffer"
                Process.exit(pid, :kill)
                {:error, "Timed out waiting for the Buffer to open a file."}
            end
      # {:error, {:function_clause, _details_list} = reason} ->
      #       IO.puts "FUNCTION CLAUSE ERROR"
      #       Logger.error
      #       {:error, reason}
      {:error, reason} ->
            {:error, reason}
    end
  end

  def start_buffer_process(%{type: :text, data: data, open_in_gui?: gui?, name: name}) do
    DynamicSupervisor.start_child(
      Flamelex.Buffer.Supervisor,
        {Buffer.Text, %{
          name: name,
          data: data,
          open_in_gui?: gui?
        }})
  end
end
