defmodule Flamelex.GUI do
  @moduledoc """
  This module provides an interface for controlling the Flamelex GUI. It
  is mostly a container for several sub-modules, which in-turn are interfaces
  for various parts of the GUI.
  """
  alias Flamelex.GUI.Controller, as: GUIControl
  alias Flamelex.Buffer.Command, as: CmdBuffer

  def reset do
    GUIControl.action(:reset)
  end

  defmodule Layout do
    def set, do: raise "Can't set a new layout!"
  end

  defmodule Frame do

    # def show,                  do: GenServer.cast(@cmd_buf, :activate)
    # def hide,                  do: GenServer.cast(@cmd_buf, :deactivate)

    def move(frame_id),        do: GUIControl.action({:move_frame, frame_id, :right_and_down_25_px})
  end

  defmodule CommandBuffer do

    #TODO this is failing
    def show,                  do: GenServer.cast(CmdBuffer, :show)
    def hide,                  do: GenServer.cast(CmdBuffer, :hide)

    def enter_character(char), do: GenServer.cast(CmdBuffer, {:enter_char, char})
    def backspace,             do: GenServer.cast(CmdBuffer, :backspace)
    def reset_text_field,      do: GenServer.cast(CmdBuffer, :reset_text_field)
    def execute_contents,      do: GenServer.cast(CmdBuffer, :execute_contents)
  end

  defmodule MenuBar do
    def show, do: Flamelex.GUI.Component.MenuBar.action(:show)
    def hide, do: Flamelex.GUI.Component.MenuBar.action(:hide)
  end

  def enable do
    raise "cant enable/disable the GUI manually yet"
  end

  def disable do
    raise "cant enable/disable the GUI manually yet"
  end

  @doc """
  Re-draw the entire GUI.
  """
  def redraw(%Scenic.Graph{} = g) do
    Flamelex.GUI.RootScene.redraw(g)
  end
end
