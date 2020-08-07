defmodule GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(params), do: Supervisor.start_link(__MODULE__, params, name: __MODULE__)

  def init(_params) do
    Logger.info("#{__MODULE__} initializing...")

    children = [
      {Scenic, viewports: [GUI.Initialize.viewport_config()]},
      GUI.Controller
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
