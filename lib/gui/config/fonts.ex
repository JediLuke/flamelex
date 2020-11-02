defmodule Flamelex.GUI.Fonts do

  def primary do
    Flamelex.GUI.FontHelpers.font_hash(:ibm_plex_mono)
  end

  @doc """
  The default font size.
  """
  def size, do: 24

end
