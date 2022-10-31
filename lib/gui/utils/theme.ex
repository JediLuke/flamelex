defmodule Flamelex.GUI.Utils.Theme do
    

    def default do
        # light()
        luke_custom()
    end

    def scenic_dark, do: %{
        active: {40, 40, 40},
        background: :black,
        border: :light_grey,
        focus: :cornflower_blue,
        highlight: :sandy_brown,
        text: :white,
        thumb: :cornflower_blue
    }

    def luke_custom, do: %{
        active: :red,
        background: :purple,
        border: :light_grey,
        focus: :cornflower_blue,
        highlight: :sandy_brown,
        text: :white,
        thumb: :cornflower_blue
    }
end