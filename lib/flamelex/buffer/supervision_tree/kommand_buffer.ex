defmodule Flamelex.Buffer.KommandBuffer do
  @moduledoc """
  This process is responsible for managing the state of the Kommand buffer.

  The KommandBuffer is special - other buffers hold & manipulate data,
  and so does the command buffer, but this data can be actioned upon to
  activate functions, achieve GUI changes etc.

  The GUI component for the KommandBuffer is drawn as part of the Default
  scene. GUIController creates the Default GUI immediately after boot &
  re-draws - so that's how the KommandBuffer GUI component gets drawn.
  """
  use Flamelex.BufferBehaviour


  @impl Flamelex.BufferBehaviour
  def boot_sequence(params) do
    IO.inspect params, label: "BOOTING KOMMAND #{inspect params}"

    Process.register(self(), __MODULE__) #TODO this process also gets named in BuferBehaviour... any issues then with doing this?

    {:ok, params}
  end


  def handle_cast(:show, state) do
    IO.puts "if this works, we hit the KommandBuffer process!!"

    #TODO this should be checking if the process exists
    {:gui_component, KommandBuffer}
    |> ProcessRegistry.find!()
    |> GenServer.cast(:show)

    {:noreply, state}
  end



  def handle_cast(:hide, state) do
    IO.puts "if this works, we hit the KommandBuffer process!!"

    #TODO this should be checking if the process exists
    {:gui_component, KommandBuffer}
    |> ProcessRegistry.find!()
    |> GenServer.cast(:hide)

    {:noreply, state}
  end





  # def handle_cast(:execute, state) do
  #   execute_command(state.data)
  #   {:noreply, %{state|data: ""}}
  # end

  # def execute_command("temet nosce") do
  #   IO.puts "!! Rebooting Flamelex !!"
  #   Flamelex.temet_nosce()
  # end

  # def execute_command("new " <> something) do
  #   case something do
  #     "note" ->
  #       raise "can't do new notes@!"
  #     otherwise ->
  #       IO.inspect otherwise
  #       IO.puts "Making new things all the time!! What a lovething #{inspect something}"
  #   end
  # end



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




  # def execute_command(unrecognised_command) do
  #   Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
  #   Code.eval_string(unrecognised_command)
  # end







  # # @impl GenServer
  # # def handle_cast(:de_activate_command_buffer, state) do
  # #   new_state = %{state|content: ""}

  # #   GenServer.cast(__MODULE__, :reset_text_field)
  # #   GUI.Component.CommandBuffer.action(:hide_command_buffer)

  # #   {:noreply, new_state} # reset the content to blank
  # # end

  # # @impl true
  # # def handle_cast({:command_buffer_command, command}, state) do

  # # end


  # # def new_note do
  # #   Franklin.BufferSupervisor.note(%{title: "", text: ""})
  # # end

  # # def list_notes do
  # #   Franklin.BufferSupervisor.list(:notes)
  # # end




end
