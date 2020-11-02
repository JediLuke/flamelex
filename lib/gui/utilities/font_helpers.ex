defmodule Flamelex.GUI.FontHelpers do
  @moduledoc """
  A place to put functions I need to stuff with fonts with. ‾\_(ツ)_/‾
  """

  @project_root_dir "/Users/luke/workbench/elixir/flamelex"
  @priv_dir @project_root_dir <> "/priv"

  #TODO font stuff should probably live more in here, less in Initialize
  def font(:ibm_plex_mono), do: Flamelex.GUI.Initialize.ibm_plex_mono_hash

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
