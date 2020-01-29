defmodule GUI.Initialize do
  @moduledoc """
  This module is responsible for providing all the Franklin GUI interface
  functions.
  """

  @title "Franklin"

  @main_viewport_config %{
    name: :main_viewport,
    size: {700, 600},
    default_scene: {GUI.Scene.Home, nil},
    drivers: [
      %{
        module: Scenic.Driver.Glfw,
        name: :glfw,
        opts: [resizeable: false, title: @title]
      }
    ]
  }

  def startup_process_childspec_list do
    [
      {Scenic, viewports: [@main_viewport_config]}
    ]
  end
end
