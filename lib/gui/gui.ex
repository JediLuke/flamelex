defmodule Flamelex.GUI do
  # various pre-defined screen resolutions
  @macbook_pro {1440, 855}
  # @window_size_macbook_pro_2 {1680, 1005}
  @monitor_32inch {2560, 1395}
  @monitor_32inch_80pc {0.8 * 2560, 0.8 * 1395}
  # with size 24 font
  @terminal_80col {800, 600}

  @artificial_manuscript {2145, 1218}

  @doc """
  This is the Scenic Viewport config, passed in to Scenic when
  we start the application (via the Supervision tree.)
  """
  def viewport_config do
    [
      name: :main_viewport,
      # size: @monitor_32inch_80pc,
      size: @macbook_pro,
      default_scene: {Flamelex.GUI.RootScene, nil},
      drivers: [
        [
          module: Scenic.Driver.Local,
          # module: Flamelex.API.ScriptAnalysis.ScriptInterceptorDriver,
          window: [title: "Flamelex", resizeable: true],
          on_close: :stop_system
        ]
      ]
    ]
  end
end
