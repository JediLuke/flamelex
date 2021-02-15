defmodule Flamelex.Utilities.ProcessRegistry do #TODO Registrar
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Structs.GUiComponentRef

  @doc """
  Register a new PiD in gproc.
  """
  def register(tag) do
    Logger.debug "#{__MODULE__} registering #{inspect tag}..."
    # https://github.com/uwiger/gproc/blob/uw-change-license/doc/gproc.md#reg3
    # :n means `name`   - and having it here enforces PiDs are registered uniquely - unique within the given context (local or global)
    # :l means `local`  - so we just register the process on this node
    :gproc.reg({:n, :l, tag})
  end

  @doc """
  Sometimes we want to use the name mechanism to register a process, e.g.

  ```
  GenServer.start_link(__MODULE__, initial_state, name: via_tuple({:buffer, "my_buf"}))
  ```
  """
  def via_tuple(tag) do
    via_tuple(:gproc, tag)
  end
  def via_tuple(:gproc, tag) do
    {:via, :gproc, {:n, :l, tag}}
  end

  #TODO deprecate above in favor of below
  @doc """
  In order to register a process using :gproc when we spawn it, we need
  to use a :via tuple. see: https://hexdocs.pm/elixir/Registry.html#module-using-in-via
  """
  def via_tuple_name(:gproc, tag) do
    via_tuple(:gproc, tag)
  end

  # #TODO this is where we wannabee, tackling the treeeee problem
  # def register_gui_component(%BufRef{ref: ref}) do
  #   register({:gui_component, ref})
  # end

  @doc """
  Returns an ok/error tuple.
  """
  # def lookup(%BufRef{ref: ref}) do
  #   lookup({:buffer, ref})
  # end
  # def lookup({:gui_component, %BufRef{ref: ref}}) do
  #   lookup({:gui_component, ref})
  # end
  # def lookup(%GUiComponentRef{} = ref) do
  #   key = GUiComponentRef.rego_tag(ref)
  #   lookup(key)
  # end
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



  ## TODO deprecate below here





  # def find_buffer({:buffer, _name} = buffer), do: find!(buffer)
  # def find_buffer(params),                    do: find!({:buffer, params})

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

  def tag(:buffer, tag) do
    register({:buffer, tag})
  end
end
