defmodule Flamelex.GUI.VimSupervisor do
  @moduledoc """
  This process is really just there as a barrier, so that if VimServer
  crashes (which happened to me a few times...) then it doesn't bring
  down the whole GUI.
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      #TODO probably needs a Task.Supervisor, and then we get VimServer to run updates in those...
      Flamelex.GUI.VimServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
