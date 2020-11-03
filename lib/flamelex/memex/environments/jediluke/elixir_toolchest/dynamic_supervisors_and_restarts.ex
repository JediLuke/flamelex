defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.DynamicSupervisorsAndRestarts do

  def description do
    ~s/
    The restart strategy for a process is defined *on that process*, not
    in the Supervisor!! So children of DynamicSupervisors need to define
    their own restart policy. e.g.

    use GenServer, restart: :temporary

    will not be restarted by a DynamicSupervisor.
    /
  end

  def references do
    [
      "https://stackoverflow.com/questions/42085240/elixir-supervisor-is-restarting-a-temporary-transient-worker-unexpectedly"
    ]
  end
end
