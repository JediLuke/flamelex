defmodule Franklin.Agent.TopLevelSupervisor do
  @moduledoc """
  This Supervisor monitors the Buffer.Manager and the Buffer.DynamicSupervisor
  """
  use Supervisor
  require Logger

  def start_link(params), do: Supervisor.start_link(__MODULE__, params, name: __MODULE__)

  def init(_params) do
    Logger.info("#{__MODULE__} initializing...")

    children = [
      {DynamicSupervisor,
            name: Franklin.Agent.DynamicSupervisor,
            strategy: :one_for_one},
      Franklin.Agent.Reminders
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
