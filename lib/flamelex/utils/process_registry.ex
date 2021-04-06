defmodule Flamelex.Utilities.ProcessRegistry do #TODO Registrar
  require Logger
  use Flamelex.ProjectAliases


  @doc """
  Register a new PiD in gproc.
  """
  def register(tag) do
    # https://github.com/uwiger/gproc/blob/uw-change-license/doc/gproc.md#reg3
    # :n means `name`  - and having it here enforces PiDs are registered uniquely - unique within the given context (local or global)
    # :l means `local` - so we just register the process on this node
    Logger.debug "ProcessRegistry - registering: #{inspect tag}..."
    :gproc.reg({:n, :l, tag})
  end


  @doc """
  Returns an ok/error tuple.
  """
  def lookup(p) when is_pid(p) do
    if Process.alive?(p) do
      {:ok, p}
    else
      {:error, "Could not find an alive process with the pid: #{inspect p}"}
    end
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
      {:ok, p} when is_pid(p) -> p
      {:error, _reason}       -> raise "Could not find a process with lookup_key: #{inspect lookup_key}"
    end
  end


  @doc """
  In order to register a process using :gproc when we spawn it, we need
  to use a :via tuple. see: https://hexdocs.pm/elixir/Registry.html#module-using-in-via
  """
  def via_tuple_name(:gproc, tag) do
    {:via, :gproc, {:n, :l, tag}}
  end

end
