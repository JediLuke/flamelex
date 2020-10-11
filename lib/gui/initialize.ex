defmodule Flamelex.GUI.Initialize do
  @moduledoc """
  This module is responsible for providing all the Franklin GUI interface
  functions.
  """

  @title "Franklin"

  #TODO rename to FLamelex, even better - use an Elixir func to get project root
  @project_root_dir "/Users/luke/workbench/elixir/franklin"
  @priv_dir @project_root_dir <> "/priv"
  @font_dir @priv_dir |> Path.join("/static/fonts")

  # IBM-Plex-Mono-Regular
  @custom_font_hash "TONjLhOjY1tqOeQUm7JnTog8VlzC_xss7NO2VKDBblA"
  @custom_metrics_path @priv_dir |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
  @custom_metrics_hash Scenic.Cache.Support.Hash.file!(@custom_metrics_path, :sha)

  @root_scene Flamelex.GUI.Root.Scene

  # @size_macbook_pro1 {1680, 1005}
  @size_macbook_pro2 {1440, 855}
  # @size_32inch_montr {2560, 1395}
  # @size_80col_termnl {800, 600}     # with size 24 font

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
    Scenic.Cache.Static.Font.load(@font_dir, @custom_font_hash, scope: :global)
    Scenic.Cache.Static.FontMetrics.load(@custom_metrics_path, @custom_metrics_hash, scope: :global)
  end

  def ibm_plex_mono_hash, do: @custom_metrics_hash

end
