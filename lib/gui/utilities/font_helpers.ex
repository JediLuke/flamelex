defmodule Flamelex.GUI.FontHelpers do
  @moduledoc """
  A place to put functions I need to stuff with fonts with. ‾\_(ツ)_/‾
  """

  @project_root_dir "/Users/luke/workbench/elixir/flamelex"
  @priv_dir @project_root_dir <> "/priv"

  def get_max_box_for_ibm_plex(font_size_in_px) do
    font_metrics =
      @priv_dir |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
      |> File.read!
      |> FontMetrics.from_binary!

    FontMetrics.max_box(font_size_in_px, font_metrics)
  end

  def monospace_font_width(:ibm_plex, font_size) do
    font_metrics =
      @priv_dir |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
      |> File.read!
      |> FontMetrics.from_binary!

    # any arbitrary character will do, it's a monospaced font
    FontMetrics.width("a", font_size, font_metrics)
  end
end
