defmodule Flamelex.GUI.ScenicInitialize do
  @moduledoc """
  Contains boot logic and default configurations required by Scenic.
  """


  # these are just some viewport sizes I find convenient
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
          name: :Flamelex
        ]
      ]
    ]
  end

  # def load_custom_fonts_into_global_cache do
  #   font = :ibm_plex_mono

  #   font_folder  = Flamelex.GUI.Fonts.project_font_directory()
  #   font_hash    = Flamelex.GUI.Fonts.font_hash(font)
  #   metrics_path = Flamelex.GUI.Fonts.metrics_path(font)
  #   metrics_hash = Flamelex.GUI.Fonts.metrics_hash(font)

  #   Scenic.Cache.Static.Font.load(font_folder, font_hash, scope: :global)
  #   Scenic.Cache.Static.FontMetrics.load(metrics_path, metrics_hash, scope: :global)
  # end
end
