defmodule Flamelex.Buffer.MiddleManager do
  @moduledoc """
  This process sits between the top supervisor, and each Buffer process.

  It also supervises a Task.Supervisor, so each Buffer can feed out work,
  allow it to crash, etc.
  """
  use Supervisor
  require Logger


  def start_link(%{source: _s, type: _t} = params) do
    Supervisor.start_link(__MODULE__, params)
  end


  def init(%{source: _s, type: _t} = params) do

    # create a unique name for the Task.Supervisor
    tag  = {:buffer, :task_supervisor, {:buffer, params.source}}
    name = Flamelex.Utils.ProcessRegistry.via_tuple_name(:gproc, tag)

    children = [
      {params.type, params}, #REMINDER: params.type is an atom, the module representing the type of Buffer this is
      {Task.Supervisor, name: name},
    ]

    # https://hexdocs.pm/elixir/Supervisor.html#module-strategies
    Supervisor.init(children, strategy: :rest_for_one)
  end



  # Registry.lookup(BufferRegistry, id)
end
