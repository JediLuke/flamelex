defmodule Flamelex.Utilities.ProcessRegistry do
  require Logger
  use Flamelex.ProjectAliases

  @valid_process_types [
    :buffer, :gui_component
  ]

  #TODO make this register 1
  def register2(:buffer, id) do
    IO.puts "REG2 buf id: #{inspect id}"
    gproc_register({:buffer, id})
  end

  def lookup(lookup_key) do
    case :gproc.where({:n, :l, lookup_key}) do
      p when is_pid(p) -> {:ok, p}
      _else            -> {:error, "Could not find a process with lookup_key: #{inspect lookup_key}"}
    end
  end

  @doc """
  Note that `find!` has a totally different name to `lookup` so that it's
  very clear when we expect a PiD (which is what `find!` returns) or an
  ok/error tuple (which is what `lookup` returns)
  """
  def find!(lookup_key) do
    case lookup(lookup_key) do
      {:ok, p}          -> p
      {:error, _reason} -> raise "Could not find a process with lookup_key: #{inspect lookup_key}"
    end
  end

  defp gproc_register(tag) do
    Logger.debug "#{__MODULE__} registering #{inspect tag}..."
    # :n means `name`, :l means `local`
    :gproc.reg({:n, :l, tag})
  end














  def register(:buffer, tag) do
    register({:buffer, tag})
  end








  def find_buffer({:buffer, _name} = buffer), do: find!(buffer)
  def find_buffer(params),                    do: find!({:buffer, params})

  # def register_buffer(params), do: register({:buffer, params})










  #TODO deprecate
  def fetch_buffer_pid(buffer_name),  do: fetch_pid({:buffer, buffer_name})
  def fetch_buffer_pid!(buffer_name), do: fetch_pid!(Buffer.rego(buffer_name))




  def fetch_pid(lookup_key) do
    case :gproc.where({:n, :l, lookup_key}) do
      p when is_pid(p) -> {:ok, p}
      _else            -> {:error, "Could not find a process with lookup_key: #{inspect lookup_key}"}
    end
  end
  def fetch_pid!(lookup_key) do
    case fetch_pid(lookup_key) do
      {:ok, p} when is_pid(p) -> p
      {:error, _reason}       -> raise "Could not find a process with lookup_key: #{inspect lookup_key}"
    end
  end

  def register(:buffer, tag) do
    register({:buffer, tag})
  end

  def register(tag) do
    Logger.debug "#{__MODULE__} registering #{inspect tag}..."
    # :n means `name`, :l means `local`
    :gproc.reg({:n, :l, tag})
  end

  #
  def tag(:buffer, tag) do
    register({:buffer, tag})
  end

  def via_tuple(tag) do
    {:via, :gproc, {:n, :l, tag}}
  end
end
