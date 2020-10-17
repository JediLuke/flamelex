defmodule Flamelex.Utilities.ProcessRegistry do
  require Logger
  use Flamelex.ProjectAliases



  def find_buffer({:buffer, _name} = buffer), do: find(buffer)
  def find_buffer(params),                    do: find({:buffer, params})

  # def register_buffer(params), do: register({:buffer, params})


  def find(lookup_key) do
    case :gproc.where({:n, :l, lookup_key}) do
      p when is_pid(p) -> {:ok, p}
      _else            -> {:error, "Could not find a process with lookup_key: #{inspect lookup_key}"}
    end
  end

  def find!(lookup_key) do
    case find(lookup_key) do
      {:ok, p}          -> p
      {:error, _reason} -> raise "Could not find a process with lookup_key: #{inspect lookup_key}"
    end
  end








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
