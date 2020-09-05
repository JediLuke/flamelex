defmodule Flamelex.Buffer.Command do
  @moduledoc """
  This process is responsible for managing the state of the Command buffer.

  The Command buffer is special - other buffers hold & manipulate data,
  and so does the command buffer, but this data is just to enable the
  CLI funtionality of Flamelex.
  """
  use GenServer
  use Flamelex.CommonDeclarations
  require Logger


  def start_link([] = _default_params) do
    initial_buffer_state = Buffer.new(:command)
    GenServer.start_link(__MODULE__, initial_buffer_state)
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%Buffer{} = buf) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)          # the Commander is a little special, doesn't use gproc
    GUI.Component.CommandBuffer.initialize(buf)   # start the Scenic.Component process
    {:ok, buf}
  end


  ## handle_cast


  def handle_cast(:activate, state) do
    GUI.Component.CommandBuffer.activate()
    {:noreply, state}
  end

  def handle_cast(:deactivate, state) do
    Flamelex.Commander.reset_text_field()
    GUI.Component.CommandBuffer.deactivate()
    {:noreply, state}
  end

  def handle_cast({:enter_char, char}, state) do
    new_state =
      case state.content do
        nil                 -> %{state|content: char}
        c when is_binary(c) -> %{state|content: state.content <> char}
      end

    GUI.Component.CommandBuffer.action({:update_content, new_state.content})
    GUI.Component.CommandBuffer.move_cursor()
    {:noreply, new_state}
  end

  def handle_cast(:reset_text_field, buf) do
    new_buffer = %{buf|content: ""}

    GUI.Component.CommandBuffer.action({:update_content, new_buffer.content})
    GUI.Component.CommandBuffer.action(:reset_cursor)

    {:noreply, new_buffer}
  end


  # def handle_cast(:backspace, %Buffer{content: ""} = buf) do
  #   {:noreply, buf}
  # end
  # def handle_cast(:backspace, %Buffer{content: c} = buf) when length(c) > 0 do
  #   {backspaced_text, _last_letter} = buf.content |> String.split_at(-1)

  #   new_buf =
  #     buf |> Buffer.update_content(with: backspaced_text)

  #   new_graph =
  #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  #     #TODO render a helper string when the buffer is empty
  #     # case new_buf.content do
  #     #   "" -> # render msg but keep text buffer as empty string
  #     #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  #     #   non_blank_string ->
  #     #     graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
  #     # end

  #   #TODO ok so this is actually it. The last step every time needs to be "updateGUI"
  #   GUI.Component.CommandBuffer.redraw(new_graph)

  #   {new_state, new_graph}


  #   {:noreply, buf}
  # end

    # def process({%{text: ""} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE') do
  #   state
  # end
  # def process({state, graph}, 'COMMAND_BUFFER_BACKSPACE') do
  #

  #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
  #   GenServer.cast(pid, {:action, 'MOVE_LEFT_ONE_COLUMN'})


  # end


  # @impl GenServer
  # def handle_cast(:deactivate_command_buffer, state) do
  #   new_state = %{state|content: ""}

  #   GenServer.cast(__MODULE__, :reset_text_field)
  #   GUI.Component.CommandBuffer.action(:hide_command_buffer)

  #   {:noreply, new_state} # reset the content to blank
  # end

  # @impl true
  # def handle_cast({:command_buffer_command, command}, state) do

  # end

  def handle_cast(:execute_contents, state) do
    execute_command(state.content)
    # deactivate() #TODO this will send :update_content and :reset_cursor again!!
    {:noreply, state}
  end

  # def new_note do
  #   Franklin.BufferSupervisor.note(%{title: "", text: ""})
  # end

  # def list_notes do
  #   Franklin.BufferSupervisor.list(:notes)
  # end

  def execute_command("reboot") do
    IO.puts "!! Rebooting Flamelex !!"
    DevTools.restart_and_recompile()
  end

  # def execute_command("new_note") do #TODO change to tidbit, with note tags
  # def execute_command("list_notes") do
  # def execute_command("reload") do
  #         Logger.warn "Sending `kill` to GUI.Scene.Root..."
  #         IEx.Helpers.recompile
  #         Process.exit(Process.whereis(GUI.Scene.Root), :kill)
  #         {:noreply, state}
  # end
  # def execute_command("restart") do
  def execute_command("note") do
    IO.puts "A new note!!"
    :ok
  end

  def execute_command("open") do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"
    Logger.info "Opening a file... #{inspect file_name}"
    Franklin.CLI.open(file: file_name) # will open as the active buffer
  end

  def execute_command("edit") do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"

    string = "Luke"
    Franklin.Buffer.Text.insert(file_name, string, after: 3)
  end

  def execute_command(unrecognised_command) do
    Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
    Code.eval_string(unrecognised_command)
  end
end
