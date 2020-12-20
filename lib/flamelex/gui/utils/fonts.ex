defmodule Flamelex.GUI.Fonts do


  #TODO this should be config driven I guess
  #TODO the font should be a config


  def primary do
    Flamelex.GUI.Fonts.font_hash(:ibm_plex_mono)
  end

  def primary(:font) do
    :ibm_plex_mono
  end

  @doc """
  The default font size.
  """
  def size, do: 24







  #TODO programatically get this instead of hard-coding it
  #Application.app_dir(:recording_services)
  # @project_root_dir "/Users/luke/workbench/elixir/flamelex"
  @project_root_dir Application.app_dir(:flamelex)
  @priv_dir @project_root_dir <> "/priv"
  @font_dir @priv_dir |> Path.join("/static/fonts")


  def project_font_directory, do: @font_dir

  def font_hash(:ibm_plex_mono) do
    "TONjLhOjY1tqOeQUm7JnTog8VlzC_xss7NO2VKDBblA"
  end

  def metrics_path(:ibm_plex_mono) do
    @priv_dir
    |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
  end

  def metrics_hash(font) do
    font
    |> metrics_path()
    |> Scenic.Cache.Support.Hash.file!(:sha)
  end

  def monospace_font_width(font = :ibm_plex_mono, font_size) do
    font_metrics =
      font
      |> metrics_path()
      |> File.read!
      |> FontMetrics.from_binary!

    # any arbitrary character will do, it's a monospaced font
    FontMetrics.width("a", font_size, font_metrics)
  end

  def monospace_font_height(font = :ibm_plex_mono, font_size) do
    font_metrics =
      font
      |> metrics_path()
      |> File.read!
      |> FontMetrics.from_binary!

    {_x_min, _y_min, _x_max, y_max} =
      FontMetrics.max_box(font_size, font_metrics)

    y_max
  end
end
