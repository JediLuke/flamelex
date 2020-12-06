defmodule Flamelex.GUI.Colors do

  def pallete do
    Flamelex.GUI.ColorsPalletes.Anakin
    # Flamelex.GUI.ColorsPalletes.Obiwan
  end

  def background do
    pallete().background()
  end

  def foreground do
    pallete().foreground()
  end


  def mode(:normal), do: :beige
  def mode(:insert), do: :green

  def menu_bar, do: :gray
end
