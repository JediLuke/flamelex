defmodule Flamelex.Buffer.KommandBuffer do
  @moduledoc """
  This process is responsible for managing the state of the Kommand buffer.

  The KommandBuffer is special - other buffers hold & manipulate data,
  and so does the command buffer, but this data can be actioned upon to
  activate functions, achieve GUI changes etc.
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







  # # def handle_cast(:backspace, %Buffer{content: ""} = buf) do
  # #   {:noreply, buf}
  # # end
  # # def handle_cast(:backspace, %Buffer{content: c} = buf) when length(c) > 0 do
  # #   {backspaced_text, _last_letter} = buf.content |> String.split_at(-1)

  # #   new_buf =
  # #     buf |> Buffer.update_content(with: backspaced_text)

  # #   new_graph =
  # #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  # #     #TODO render a helper string when the buffer is empty
  # #     # case new_buf.content do
  # #     #   "" -> # render msg but keep text buffer as empty string
  # #     #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  # #     #   non_blank_string ->
  # #     #     graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
  # #     # end

  # #   #TODO ok so this is actually it. The last step every time needs to be "updateGUI"
  # #   GUI.Component.CommandBuffer.redraw(new_graph)

  # #   {new_state, new_graph}


  # #   {:noreply, buf}
  # # end

  #   # def process({%{text: ""} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE') do
  # #   state
  # # end
  # # def process({state, graph}, 'COMMAND_BUFFER_BACKSPACE') do
  # #

  # #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  # #   GenServer.cast(pid, {:action, 'MOVE_LEFT_ONE_COLUMN'})


  # # end


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
