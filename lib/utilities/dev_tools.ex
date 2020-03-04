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
    Franklin.Commander.new_note()
  end
end
