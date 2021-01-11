defmodule Flamelex.Fluxus.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    children = [
      {Task.Supervisor, name: Flamelex.Omega.Input2ActionLookup.TaskSupervisor},
      {Task.Supervisor, name: Flamelex.Omega.HandleAction.TaskSupervisor},
      Flamelex.OmegaMaster
    ]

    Supervisor.init(children, strategy: :one_for_all) #TODO make this :rest_for_one?
  end
end
