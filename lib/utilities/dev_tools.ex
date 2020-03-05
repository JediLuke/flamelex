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

  def root_state do
    :sys.get_state(GUI.Scene.Root)
  end

  def file_write do
    r = File.cwd!
    IO.inspect r

    {:ok, file} = File.open("./data/franklin.data", [:write])
    IO.binwrite(file, "world")
    File.close(file)

    {:ok, file_contents} = File.read("./data/franklin.data")
    file_contents
  end
end
