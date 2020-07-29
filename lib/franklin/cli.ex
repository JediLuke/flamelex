defmodule Franklin.CLI do
  @moduledoc """
  Contains functions intended to be used on the IEx console.
  """

  def help do
    raise "No help to be found."
    # GUI.open_buffer(%{text: "No help to be found."}) #TODO probably use some kind of Buffer struct here
  end

  def open(file: filepath) do
    with {:ok, text} <- File.read(filepath),
         {:ok, _buf} <- GUI.new_buffer(text: text), do: :ok
  end

  def new_note do
    raise "This works but don't know how?? see `Franklin.Commander.new_note`"
  end

  def new_blank_text_file do
    raise "Not implemented yet" #TODO open in insert mode already
  end

  def reminders do
    raise "Not implemented yet"
  end

  def new_reminder(r) do
    raise "not implemented yet"
  end

  # command buffer commands
  def activate_command_buffer,   do: Franklin.Actions.CommandBuffer.activate()
  def deactivate_command_buffer, do: Franklin.Actions.CommandBuffer.deactivate()

  def reload_and_restart do
    raise "Epic fail lulz"
  end
end
