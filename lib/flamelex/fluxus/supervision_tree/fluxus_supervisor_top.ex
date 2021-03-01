defmodule Flamelex.Fluxus.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    children = [
      # Flamelex.Fluxus.Stash, #TODO this is a rly cool concept
      {Task.Supervisor, name: Flamelex.Fluxus.InputHandler.TaskSupervisor},
      {Task.Supervisor, name: Flamelex.Fluxus.RootReducer.TaskSupervisor},
      Flamelex.FluxusRadix
    ]

    Supervisor.init(children, strategy: :one_for_all) #TODO make this :rest_for_one?
  end
end
