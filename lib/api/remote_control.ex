defmodule Flamelex.API.RemoteControl do
  @moduledoc """
  Remote control interface for Flamelex.
  Allows external control via MCP or other interfaces.
  """
  
  require Logger
  
  @doc """
  Send a key event to the GUI system
  """
  def send_key_event(key, modifiers \\ []) do
    try do
      # Convert to appropriate format for Scenic/GLFW
      event = {:key, {key, :press, modifiers}}
      
      # Send to the GUI process
      case GenServer.whereis(Flamelex.GUI) do
        nil -> 
          {:error, "GUI process not found"}
        pid ->
          GenServer.cast(pid, {:input_event, event})
          {:ok, "Key event sent: #{inspect(key)}"}
      end
    rescue
      e -> 
        {:error, "Failed to send key event: #{inspect(e)}"}
    end
  end
  
  @doc """
  Send text input to the GUI
  """
  def send_text(text) when is_binary(text) do
    try do
      # Split text into individual characters and send as key events
      text
      |> String.graphemes()
      |> Enum.each(fn char ->
        send_key_event(char, [])
        # Small delay between characters
        Process.sleep(10)
      end)
      
      {:ok, "Text sent: #{text}"}
    rescue
      e -> 
        {:error, "Failed to send text: #{inspect(e)}"}
    end
  end
  
  @doc """
  Send a mouse click event
  """
  def send_mouse_click(x, y, button \\ :left) do
    try do
      # Create mouse click event
      event = {:cursor_button, {button, :press, 0, {x, y}}}
      
      # Send to the GUI process
      case GenServer.whereis(Flamelex.GUI) do
        nil -> 
          {:error, "GUI process not found"}
        pid ->
          GenServer.cast(pid, {:input_event, event})
          # Also send release event
          release_event = {:cursor_button, {button, :release, 0, {x, y}}}
          GenServer.cast(pid, {:input_event, release_event})
          {:ok, "Mouse click sent at (#{x}, #{y})"}
      end
    rescue
      e -> 
        {:error, "Failed to send mouse click: #{inspect(e)}"}
    end
  end
  
  @doc """
  Open a new buffer with specified content
  """
  def open_buffer_with_text(text) do
    try do
      # This is a simplified approach - would need to be adapted to actual Flamelex buffer API
      send_key_event(:ctrl_n, [:ctrl])  # Ctrl+N for new buffer (common shortcut)
      Process.sleep(100)
      send_text(text)
      {:ok, "Buffer opened with text: #{text}"}
    rescue
      e -> 
        {:error, "Failed to open buffer: #{inspect(e)}"}
    end
  end
  
  @doc """
  Get current GUI state for debugging
  """
  def get_gui_state do
    try do
      processes = Process.list()
      gui_processes = Enum.filter(processes, fn pid ->
        case Process.info(pid, :registered_name) do
          {:registered_name, name} when is_atom(name) ->
            name_str = Atom.to_string(name)
            String.contains?(name_str, "GUI") or String.contains?(name_str, "Scenic")
          _ -> false
        end
      end)
      
      %{
        gui_processes: length(gui_processes),
        flamelex_gui: GenServer.whereis(Flamelex.GUI),
        timestamp: DateTime.utc_now()
      }
    rescue
      e -> 
        {:error, "Failed to get GUI state: #{inspect(e)}"}
    end
  end
end
