defmodule Flamelex.GUI.FontHelpers do
  @moduledoc """
  A place to put functions I need to stuff with fonts with. ‾\_(ツ)_/‾
  """


  #TODO programatically get this instead of hard-coding it
  @project_root_dir "/Users/luke/workbench/elixir/flamelex"
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


  @doc """
  Get the box size for a font.

  iex> GUI.FontHelpers.get_max_box_for_ibm_plex(text_size)
  {_x_min, _y_min, _x_max, y_max}
  """
  # def get_max_box_for_ibm_plex(font_size_in_px) do
  #   font_metrics = read_font_metrics(:ibm_plex_mono)

  #   FontMetrics.max_box(font_size_in_px, font_metrics)
  # end

  def monospace_font_width(:ibm_plex_mono, font_size) do
    font_metrics = read_font_metrics(:ibm_plex_mono)

    # any arbitrary character will do, it's a monospaced font
    FontMetrics.width("a", font_size, font_metrics)
  end

  def monospace_font_height(:ibm_plex_mono, font_size) do
    font_metrics = read_font_metrics(:ibm_plex_mono)

    {_x_min, _y_min, _x_max, y_max} =
      FontMetrics.max_box(font_size, font_metrics)

    y_max
  end

  def read_font_metrics(:ibm_plex_mono) do
    @priv_dir
    |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
    |> File.read!
    |> FontMetrics.from_binary!
  end
end
