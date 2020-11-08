defmodule Franklin.OldCLI do
  # @moduledoc """
  # Contains functions intended to be used on the IEx console.
  # """
  # # import Utilities.ProcessRegistry

  # alias Franklin.Buffer.Supervisor, as: BufrSup

  # def help do
  #   raise "No help to be found."
  #   # GUI.open_buffer(%Buffer{type: :text, content: "No help to be found."})
  # end

  # def open(file: filepath), do: open(file: filepath, type: :text) # by default
  # def open(file: filepath, type: :text) do
  #   {:ok, text} = File.read(filepath)
  #   {:ok, _pid} = BufrSup.start_buffer(type: :text, name: filepath, content: text)
  # end
  # def open(url: _url) do
  #   raise "Can't read URLs yet"
  # end

  # # def edit(insert: string, at: :current_location) do
  # #   edit(buffer: :active, insert: string, at: :current_location)
  # # end
  # # def edit(buffer: :active, insert: string, after: x) when x >= 0 do
  # #   #
  # #   # find the active buffer & insert a character where the cursor is
  # #   # Flamelex.GUI.Controller.fetch_active_buffer()
  # #   Franklin.Flamelex.Buffer.Text.insert(:active_buffer, string, after: 7)

  # #   # fetch_buffer_pid!("unnamed")
  # #   # |> IO.inspect(label: "Active buf")
  # #   # |> Franklin.Flamelex.Buffer.Text.insert(char, after: 7)
  # # end

  # def scroll(buffer: :active, direction: :down) do
  #   raise "not yet"
  # end






  # def new_note do
  #   raise "This works but don't know how?? see `Franklin.Commander.new_note`"
  # end

  # def new_whiteboard do

  # end

  # def new_blank_text_file do
  #   raise "Not implemented yet" #TODO open in insert mode already
  # end

  # def new_list_buffer do
  #   raise "lol?"
  #   #   alias GUI.Scene.Root, as: Franklin
  #   #   def new_buffer(:test) do
  #   #     new_buffer(%{
  #   #       type: :list,
  #   #       data: [
  #   #         {"iderieri", %{
  #   #           title: "Luke",
  #   #           text: "First note"
  #   #         }},
  #   #         {"ikey-heihderieri", %{
  #   #           title: "Leah",
  #   #           text: "Second note"
  #   #         }}
  #   #       ]
  #   #     })
  #   #   end

  #   #   def new_buffer(%{type: :list, data: data}) do
  #   #     Franklin.action({'NEW_LIST_BUFFER', data})
  #   #   end
  # end

  # def reminders do
  #   raise "Not implemented yet"
  # end

  # def save_new_tidbit do
  #   raise "Nope not yet"
  #   # Utilities.Data.append(t)
  # end

  # def new_reminder(r) do
  #   raise "not implemented yet"
  # end

  # def reload_and_restart do
  #   raise "Epic fail lulz"
  # end
end



















defmodule Flamelex.DevTools do

  # defmacro __using__(_) do
  #   quote do
  #     import DevTools
  #     import Utilities.ProcessRegistry
  #     alias Flamelex.Commander
  #   end
  # end

  # def recompile, do: IEx.Helpers.recompile

  # def restart_and_recompile do
  #   Application.stop(:franklin)
  #   IEx.Helpers.recompile
  #   Application.start(:franklin)
  # end

  def fire_dev_loop_with_restart do
    # restart_and_recompile()
    fire_dev_loop()
  end

  def fire_dev_loop do
    IEx.Helpers.recompile()

    # open_file_in_buffer()
    # activate_command_buffer()
    Commander.enter_character("e")
  end

  def open_file_in_buffer do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"
    Franklin.CLI.open(file: file_name) # will open as the active buffer

    # Franklin.CLI.open(file: "/Users/luke/workbench/elixir/franklin/README.md")
    # Franklin.CLI.edit(buffer: :active, insert: "Luke", after: 4)

    string = "Luke"

    Franklin.Flamelex.Buffer.Text.insert(file_name, string, after: 3)

    # fetch_buffer_pid!(file_name)
    # |> Franklin.Flamelex.Buffer.Text.insert(string, [after: 7])

    :ok
  end



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
