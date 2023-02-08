defmodule Flamelex.App do
  @moduledoc false
  use Application
  require Logger


  def start(_type, _args) do
    #Logger.debug "#{__MODULE__} initializing..."

    children = [
      #NOTE: Fluxus has to come before the GUI because
      # GUI calls RadixStore to get it's init state
      #TODO maybe we should pass it in to both from this top level??
      Flamelex.Fluxus.TopLevelSupervisor,
      {Scenic, [viewport_config()]}
    ]

    children = if boot_memelex?(),
                    do: children ++ [Memelex.App.BootLoader],
                  else: children

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end


  @macbook_pro {1440, 855}
  @window_size_macbook_pro_2 {1680, 1005}
  @window_size_monitor_32inch {2560, 1395}
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

  def boot_memelex? do
    Application.get_env(:memelex, :active?, false)
  end
end
