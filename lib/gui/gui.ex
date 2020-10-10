defmodule GUI do
  @moduledoc """
  This module provides an interface for controlling the Flamelex GUI.


  One important point about this module is that it is intended to be used
  as a library by other higher-level processes & modules, not directly
  interacted with by the user (even though this would be easy to do via the
  command line). For example, when putting
  """
  # use Flamelex.CommonDeclarations

  @doc """
  This function displays the Commander.
  """
  # def activate_command_buffer do
  #   GenServer.cast(Flamelex.GUI.Controller, :activate_command_buffer)
  # end

  @doc """
  This function hides the Commander, and clears any text which had
  been entered into it.
  """
  # def de_activate_command_buffer do
  #   GenServer.cast(Flamelex.GUI.Controller, :de_activate_command_buffer)
  # end

  # def display_buffer(%Buffer{} = buf) do
  #   #TODO use a struct here
  #   # def show_fullscreen(buffer), do: Flamelex.GUI.Controller.show_fullscreen(buffer)
  #   # def show_fullscreen(buffer), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN
  #   # def register_new_buffer(type: :text, content: content, action: 'OPEN_FULL_SCREEN'), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: content]})
  #   # def register_new_buffer(args), do: Flamelex.GUI.Controller.register_new_buffer(args)
  #   GenServer.cast(Flamelex.GUI.Controller, {:display_buffer, buf})
  # end

  # def register_new_buffer(args), do: GenServer.cast(__MODULE__, {:register_new_buffer, args})

  # def show_fullscreen(buffer), do: GenServer.cast(__MODULE__, {:show_fullscreen, buffer})

  # def fetch_active_buffer(), do: GenServer.call(__MODULE__, :fetch_active_buffer)

  defmodule Frame do
    def show() do
      raise "lol"
    end

    def hide do
      raise "rofl"
    end

    def move(frame_id) do
      Flamelex.GUI.Controller.action({:move_frame, frame_id, :right_and_down_25_px})
    end
  end

  defmodule MenuBar do
    def show() do
      #TODO: request Gui.Commander to show menubar based on current layout
    end

    def hide do
      raise "rofl"
    end
  end
end
