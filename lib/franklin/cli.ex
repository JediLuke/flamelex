defmodule Franklin.CLI do
  @moduledoc """
  Contains functions intended to be used on the IEx console.
  """
  # import Utilities.ProcessRegistry

  alias Franklin.Buffer.Supervisor, as: BufrSup

  def help do
    raise "No help to be found."
    # GUI.open_buffer(%Buffer{type: :text, content: "No help to be found."})
  end

  def open(file: filepath), do: open(file: filepath, type: :text) # by default
  def open(file: filepath, type: :text) do
    {:ok, text} = File.read(filepath)
    {:ok, _pid} = BufrSup.start_buffer(type: :text, name: filepath, content: text)
  end
  def open(url: _url) do
    raise "Can't read URLs yet"
  end

  # def edit(insert: string, at: :current_location) do
  #   edit(buffer: :active, insert: string, at: :current_location)
  # end
  # def edit(buffer: :active, insert: string, after: x) when x >= 0 do
  #   #
  #   # find the active buffer & insert a character where the cursor is
  #   # GUI.Controller.fetch_active_buffer()
  #   Franklin.Buffer.Text.insert(:active_buffer, string, after: 7)

  #   # fetch_buffer_pid!("unnamed")
  #   # |> IO.inspect(label: "Active buf")
  #   # |> Franklin.Buffer.Text.insert(char, after: 7)
  # end

  def scroll(buffer: :active, direction: :down) do
    raise "not yet"
  end






  def new_note do
    raise "This works but don't know how?? see `Franklin.Commander.new_note`"
  end

  def new_whiteboard do

  end

  def new_blank_text_file do
    raise "Not implemented yet" #TODO open in insert mode already
  end

  def new_list_buffer do
    raise "lol?"
    #   alias GUI.Scene.Root, as: Franklin
    #   def new_buffer(:test) do
    #     new_buffer(%{
    #       type: :list,
    #       data: [
    #         {"iderieri", %{
    #           title: "Luke",
    #           text: "First note"
    #         }},
    #         {"ikey-heihderieri", %{
    #           title: "Leah",
    #           text: "Second note"
    #         }}
    #       ]
    #     })
    #   end

    #   def new_buffer(%{type: :list, data: data}) do
    #     Franklin.action({'NEW_LIST_BUFFER', data})
    #   end
  end

  def reminders do
    raise "Not implemented yet"
  end

  def save_new_tidbit do
    raise "Nope not yet"
    # Utilities.Data.append(t)
  end

  def new_reminder(r) do
    raise "not implemented yet"
  end

  def reload_and_restart do
    raise "Epic fail lulz"
  end
end
