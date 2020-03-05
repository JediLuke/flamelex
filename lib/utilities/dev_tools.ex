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

    data = %{
      author: "Luke",
      project: "Franklin"
    } |> Jason.encode!

    IO.inspect data, label: "DDD"

    IO.binwrite(file, data)
    File.close(file)

    {:ok, file_contents} = File.read("./data/franklin.data")
    file_contents |> Jason.decode!
  end
end
