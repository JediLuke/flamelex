defmodule Flamelex.Buffer.Utils.KommandBuffer.ExecuteCommandHelper do
  require Logger


  def execute_command("temet nosce") do
    IO.puts "!! Rebooting Flamelex !!"
    Flamelex.temet_nosce()
  end

  # def execute_command("new " <> something) do
  #   case something do
  #     "note" ->
  #       raise "can't do new notes@!"
  #     otherwise ->
  #       IO.inspect otherwise
  #       IO.puts "Making new things all the time!! What a lovething #{inspect something}"
  #   end
  # end

  def execute_command("book") do
    Flamelex.API.Buffer.open!("/Users/luke/Documents/Writing/book1.txt")
  end


  # # def execute_command("open") do
  # #   file_name = "/Users/luke/workbench/elixir/flamelex/README.md"
  # #   Logger.info "Opening a file... #{inspect file_name}"
  # #   Flamelex.CLI.open(file: file_name) # will open as the active buffer
  # # end

  # # def execute_command("edit") do
  # #   file_name = "/Users/luke/workbench/elixir/flamelex/README.md"

  # #   string = "Luke"
  # #   Flamelex.Buffer.Text.insert(file_name, string, after: 3)
  # # end




  def execute_command(unrecognised_command) do
    Logger.warn "Running KommandBuffer contents as Elixir code..."
    Code.eval_string(unrecognised_command)
  end



  # # def new_note do
  # #   Franklin.BufferSupervisor.note(%{title: "", text: ""})
  # # end

  # # def list_notes do
  # #   Franklin.BufferSupervisor.list(:notes)
  # # end





end
