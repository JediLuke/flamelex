defmodule Flamelex.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger



  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.debug "#{__MODULE__} initializing..."

    children = [
      {Scenic, [viewport_config()]},
      Flamelex.GUI.Controller,
      Flamelex.GUI.VimSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end


  @macbook_pro {1440, 855}
  # @window_size_macbook_pro_2 {1680, 1005}
  # @window_size_monitor_32inch {2560, 1395}
  # @window_size_terminal_80col {800, 600}   # with size 24 font

  def viewport_config do
    [
      name: :main_viewport,
      size: @macbook_pro,
      default_scene: {Flamelex.GUI.RootScene, nil},
      drivers: [
        [
          module: Scenic.Driver.Local,
          window: [title: "Flamelex", resizeable: true],
          on_close: :stop_system
        ]
      ]
    ]
  end

end
