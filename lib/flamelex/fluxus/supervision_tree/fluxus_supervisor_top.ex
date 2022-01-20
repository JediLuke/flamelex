defmodule Flamelex.Fluxus.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.debug "#{__MODULE__} initializing..."

    children = [
      #TODO these can both fuck off now that we're moving to tht EventBus
      # {Task.Supervisor, name: Flamelex.Fluxus.InputHandler.TaskSupervisor},
      # {Task.Supervisor, name: Flamelex.Fluxus.RootReducer.TaskSupervisor},
      
      Flamelex.Fluxus.Stash,
      Flamelex.FluxusRadix,
      Flamelex.Fluxus.ActionListener
    ]

    Supervisor.init(children, strategy: :one_for_all) #TODO make this :rest_for_one?
  end
end
