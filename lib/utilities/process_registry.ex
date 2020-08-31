defmodule Utilities.ProcessRegistry do
  require Logger

  def fetch_buffer_pid(buffer_name),  do: fetch_pid({:buffer, buffer_name})
  def fetch_buffer_pid!(buffer_name), do: fetch_pid!(Structs.Buffer.rego(buffer_name))

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

  def register(tag) do
    Logger.info "#{__MODULE__} registering #{inspect tag}..."
    # :n means `name`, :l means `local`
    :gproc.reg({:n, :l, tag})
  end

  # def via_tuple(tag) do
  #   {:via, :gproc, {:n, :l, tag}}
  # end
end
