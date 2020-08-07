defmodule DevTools do
  # alias Structs.Buffer
  import Utilities.ProcessRegistry

  defmacro __using__(_) do
    quote do
      import DevTools
      import Utilities.ProcessRegistry
    end
  end

  def recompile, do: IEx.Helpers.recompile

  def restart_and_recompile do
    Application.stop(:franklin)
    IEx.Helpers.recompile
    Application.start(:franklin)
  end

  def fire_dev_loop_with_restart do
    restart_and_recompile()
    fire_dev_loop()
  end

  def fire_dev_loop do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"
    Franklin.CLI.open(file: file_name) # will open as the active buffer

    # Franklin.CLI.open(file: "/Users/luke/workbench/elixir/franklin/README.md")
    # Franklin.CLI.edit(buffer: :active, insert: "Luke", after: 4)

    string = "Luke"

    # %Buffer{name: file_name, type: :text}

    fetch_buffer_pid!(file_name) |> Franklin.Buffer.Text.insert(string, [after: 7])

    :fin
  end

  # command buffer commands
  def activate_command_buffer,   do: Franklin.Actions.CommandBuffer.activate()
  def deactivate_command_buffer, do: Franklin.Actions.CommandBuffer.deactivate()

  # def new_note do
  #   Franklin.Commander.new_note()
  # end

  def gui_root_state, do: :sys.get_state(GUI.Scene.Root)

  # def file_write do
  #   r = File.cwd!
  #   IO.inspect r

  #   {:ok, file} = File.open("./data/franklin.data", [:write])

  #   data = %{
  #     author: "Luke",
  #     project: "Franklin"
  #   } |> Jason.encode!

  #   IO.inspect data, label: "DDD"

  #   IO.binwrite(file, data)
  #   File.close(file)

  #   {:ok, file_contents} = File.read("./data/franklin.data")
  #   file_contents |> Jason.decode!
  # end

  # @project_root_dir "/Users/luke/workbench/elixir/franklin"
  # @priv_dir @project_root_dir <> "/priv"

  # def font_metrics do
  #   @priv_dir |> Path.join("/static/fonts/IBM-Plex-Mono/IBMPlexMono-Regular.ttf.metrics")
  #   |> File.read!
  #   |> FontMetrics.from_binary!
  # end

  # def tidbit_save do
  #   Structs.TidBit.initialize(%{title: "A dev TidBit", tags: ["luke"], content: "That's my name!"})
  #   |> Actions.save_new_tidbit()
  # end
  # def tidbit_save(title, content, tags) do
  #   Structs.TidBit.initialize(%{title: title, tags: tags, content: content})
  #   |> Actions.save_new_tidbit()
  # end
  # def tidbit_save(title, content, tags, extra_metadata) do
  #   Structs.TidBit.initialize(%{title: title, tags: tags, content: content} |> Map.merge(extra_metadata))
  #   |> Actions.save_new_tidbit()
  # end

  # def new_reminder(title, content, tags \\ []) do
  #   #TODO remind me in 12 seconds
  #   tidbit_save(title, content, tags ++ ["reminder"], %{remind_me_datetime: DateTime.utc_now() |> DateTime.add(3600, :second)})
  # end
end
