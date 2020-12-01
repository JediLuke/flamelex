defmodule Flamelex.API.GUI.Fonts do

  def primary do
    Flamelex.API.GUI.FontHelpers.font_hash(:ibm_plex_mono)
  end

  @doc """
  The default font size.
  """
  def size, do: 24

end
