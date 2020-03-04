defmodule GUI.Initialize do
  @moduledoc """
  This module is responsible for providing all the Franklin GUI interface
  functions.
  """

  @title "Franklin"

  # custom font - IBM-Plex-Mono
  @project_root_dir "/Users/luke/workbench/elixir/franklin"
  @priv_dir @project_root_dir <> "/priv"
  @font_folder @priv_dir |> Path.join("/static/fonts")
  @custom_font_hash "TONjLhOjY1tqOeQUm7JnTog8VlzC_xss7NO2VKDBblA" # IBM-Plex-Mono-Regular
  @custom_metrics_path @priv_dir |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
  @custom_metrics_hash Scenic.Cache.Support.Hash.file!(@custom_metrics_path, :sha)

  @main_viewport_config %{
    name: :main_viewport,
    # size: {1680, 1005},
    # size: {1440, 855}, # macbook pro screen res
    size: {2560, 1395}, # 32" BenQ full screen
    default_scene: {GUI.Scene.Root, nil},
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

  def load_custom_fonts_into_global_cache do
    Scenic.Cache.Static.Font.load(@font_folder, @custom_font_hash, scope: :global)
    Scenic.Cache.Static.FontMetrics.load(@custom_metrics_path, @custom_metrics_hash, scope: :global)
  end

  def ibm_plex_mono_hash, do: @custom_metrics_hash

end
