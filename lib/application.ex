defmodule Flamelex.Application do
  @moduledoc false
  use Application
  require Logger


  def start(_type, _args) do

    Logger.debug "#{__MODULE__} initializing..."

    children = [
      Flamelex.Fluxus.TopLevelSupervisor,
      Flamelex.Buffer.TopLevelSupervisor,
      Flamelex.GUI.TopLevelSupervisor
      # {Scenic, [viewport_config()]}
    ]

    opts = [strategy: :one_for_one, name: Flamelex.Trismegistus]
    Supervisor.start_link(children, opts)
  end

  # def viewport_config do
  #   [
  #     name: :main_viewport,
  #     size: {1000, 1000},
  #     default_scene: {Flamelex.GUI.RootScene, nil},
  #     drivers: [
  #       [
  #         module: Scenic.Driver.Local,
  #         name: :local
  #       ]
  #     ]
  #   ]
  # end

end
