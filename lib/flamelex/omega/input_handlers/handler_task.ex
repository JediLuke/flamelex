defmodule Flamelex.GUI.InputHandler.Task do
  use Task
  # REMINDER: A Task has a default :restart of :temporary. This means
  #           the task will not be restarted even if it crashes.

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
    # ...
  end
end
