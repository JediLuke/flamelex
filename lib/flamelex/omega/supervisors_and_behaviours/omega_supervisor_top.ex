defmodule Flamelex.Omega.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.info("#{__MODULE__} initializing...")

    children = [
      {Task.Supervisor, name: Flamelex.Omega.UserInput.TaskSupervisor},
      Flamelex.OmegaMaster
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end