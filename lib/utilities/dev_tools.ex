defmodule DevTools do
  defmacro __using__(_) do
    quote do
      import DevTools
    end
  end

  def restart do
    IEx.Helpers.recompile
    Application.stop(:franklin)
    Application.start(:franklin)
  end

  def new_note do
    GUI.Scene.Root.action('NEW_NOTE_COMMAND')
  end
end
