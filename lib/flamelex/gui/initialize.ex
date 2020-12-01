defmodule Flamelex.GUI.Initialize do
  @moduledoc """
  Contains boot logic and default configurations required by Scenic.
  """

  @title "Flamelex"

  # viewport sizes for various screens
  # @size_macbook_pro1 {1680, 1005}
  @size_macbook_pro2 {1440, 855}
  # @size_32inch_montr {2560, 1395}
  # @size_80col_termnl {800, 600}     # with size 24 font


  @root_scene Flamelex.GUI.RootScene


  @main_viewport_config %{
    name: :main_viewport,
    size: @size_macbook_pro2,
    default_scene: {@root_scene, nil},
    drivers: [
      %{
        module: Scenic.Driver.Glfw,
        name: :glfw,
        opts: [resizeable: false, title: @title]
      }
    ]
  }

  def scenic_childspec do
    {Scenic, viewports: [@main_viewport_config]}
  end

  def viewport_config do
    @main_viewport_config
  end

  def load_custom_fonts_into_global_cache do
    font = :ibm_plex_mono

    font_path    = Flamelex.API.GUI.FontHelpers.project_font_directory()
    font_hash    = Flamelex.API.GUI.FontHelpers.font_hash(font)
    metrics_path = Flamelex.API.GUI.FontHelpers.metrics_path(font)
    metrics_hash = Flamelex.API.GUI.FontHelpers.metrics_hash(font)

    Scenic.Cache.Static.Font.load(font_path, font_hash, scope: :global)
    Scenic.Cache.Static.FontMetrics.load(metrics_path, metrics_hash, scope: :global)
  end

end
