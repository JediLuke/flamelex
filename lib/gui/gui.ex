defmodule Flamelex.GUI do
  @moduledoc """
  This module provides an interface for controlling the Flamelex GUI. It
  is mostly a container for several sub-modules, which in-turn are interfaces
  for various parts of the GUI.
  """
  use Flamelex.ProjectAliases

  defmodule Layout do
    def set, do: raise "Can't set a new layout!"
  end

  defmodule Frame do

    # def show,                  do: GenServer.cast(@cmd_buf, :activate)
    # def hide,                  do: GenServer.cast(@cmd_buf, :deactivate)

    def move(frame_id),        do: GUiControl.action({:move_frame, frame_id, :right_and_down_25_px})
  end

  defmodule CommandBuffer do
    @cmd_bufr Flamelex.Buffer.Command

    def show,                  do: GenServer.cast(@cmd_bufr, :activate)
    def hide,                  do: GenServer.cast(@cmd_bufr, :deactivate)

    def enter_character(char), do: GenServer.cast(@cmd_bufr, {:enter_char, char})
    def backspace,             do: GenServer.cast(@cmd_bufr, :backspace)
    def reset_text_field,      do: GenServer.cast(@cmd_bufr, :reset_text_field)
    def execute_contents,      do: GenServer.cast(@cmd_bufr, :execute_contents)
  end

  defmodule MenuBar do

    # def show,   do: GenServer.cast(@cmd_buf, :activate)
    # def hide,   do: GenServer.cast(@cmd_buf, :deactivate)

  end

  @doc """
  Re-draw the entire GUI.
  """
  def redraw(%Scenic.Graph{} = g) do
    Flamelex.GUI.Root.Scene.redraw(g)
  end
end
