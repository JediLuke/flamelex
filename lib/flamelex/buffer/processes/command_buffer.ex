defmodule Flamelex.Buffer.Command do
  @moduledoc """
  This process is responsible for managing the state of the Command buffer.

  The Command buffer is special - other buffers hold & manipulate data,
  and so does the command buffer, but this data can be actioned upon to
  activate functions, achieve GUI changes etc.
  """
  use GenServer
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.GUI.Component.CommandBuffer, as: GUIComponent


  def start_link([] = _default_params) do
    name = ProcessRegistry.via_tuple({:buffer, __MODULE__})
    # initial_buffer_state = Buffer.new(:command)
    initial_state = %{data: ""}
    GenServer.start_link(__MODULE__, initial_state, name: name)
  end

  @doc """
  Empty out the contents of the buffer.
  """
  def clear do
    ProcessRegistry.find!({:buffer, __MODULE__})
    |> GenServer.cast(:clear)
  end

  def cast(x) do
    ProcessRegistry.find!({:buffer, __MODULE__})
    |> GenServer.cast(x)
  end


  #TODO how do we know when the pid of our counterpart GUI.Comnponent is?? Is it booted yet??
    # def handle_continue(:init_gui, buf) do
  #   GUI.Component.CommandBuffer.initialize(buf)   # start the Scenic.Component process
  #   {:noreply, buf}
  # end



  ## GenServer callbacks
  ## -------------------------------------------------------------------


  # def init(%Buf{} = buf) do
  def init(buf) do
    IO.puts "#{__MODULE__} initializing...\n" # NOTE: This is the last process we boot in the initial supervision tree, so in thie special case we add a `\n` character to the log output, just for neatness.

    #TODO link to the command buffer GUI process - can we just use grpoc to talk to it??

    {:ok, buf}
  end


  # def handle_call(:read_contents, _from, %{data: nil} = state) do
  #   {:reply, "", state}
  # end

  def handle_call(:read, _from, %{data: data} = state) do
    {:reply, data, state}
  end

  def handle_cast(:clear, state) do

  # defp reset_text_field(buf) do
  #   new_buffer = %{buf|content: ""}

  #   GUI.Component.CommandBuffer.action({:update_content, new_buffer.content})
  #   GUI.Component.CommandBuffer.action(:reset_cursor)

  #   new_buffer
  # end
    {:noreply, %{state|data: ""}}
  end

  def handle_cast(:execute, state) do
    execute_command(state.data)
    {:noreply, %{state|data: ""}}
  end

  def execute_command("temet nosce") do
    IO.puts "!! Rebooting Flamelex !!"
    Flamelex.temet_nosce()
  end

  def execute_command("new " <> something) do
    case something do
      "note" ->
        raise "can't do new notes@!"
      otherwise ->
        IO.inspect otherwise
        IO.puts "Making new things all the time!! What a lovething #{inspect something}"
    end
  end



  # def execute_command("open") do
  #   file_name = "/Users/luke/workbench/elixir/flamelex/README.md"
  #   Logger.info "Opening a file... #{inspect file_name}"
  #   Flamelex.CLI.open(file: file_name) # will open as the active buffer
  # end

  # def execute_command("edit") do
  #   file_name = "/Users/luke/workbench/elixir/flamelex/README.md"

  #   string = "Luke"
  #   Flamelex.Buffer.Text.insert(file_name, string, after: 3)
  # end




  def execute_command(unrecognised_command) do
    Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
    Code.eval_string(unrecognised_command)
  end





  #TODO this input handling here is fkin stupid, should just be getting events by this stage
  def handle_cast({:input, {:key, {_letter, :press, _num}}}, state) do

    # new_state =
    #   case state.data do
    #     nil                   -> %{state|data: letter}                # enter the first character
    #     ii when is_binary(ii) -> %{state|data: state.data <> letter}  # append the char to current content
    #   end

    # GUIComponent.update({:text, new_state.data})
    # GUI.Component.CommandBuffer.action({:update_content, new_state.content})
    # GUI.Component.CommandBuffer.action(:move_cursor)

    # {:noreply, new_state}
    {:noreply, state}
  end

  def handle_cast({:input, {:codepoint, {letter, _num}}}, state) do

    IO.puts "CODEPOINT"
    new_state =
      case state.data do
        nil                   -> %{state|data: letter}                # enter the first character
        ii when is_binary(ii) -> %{state|data: state.data <> letter}  # append the char to current content
      end

    GUIComponent.update({:text, new_state.data})
    # GUI.Component.CommandBuffer.action({:update_content, new_state.content})
    # GUI.Component.CommandBuffer.action(:move_cursor)

    {:noreply, new_state}
  end



  # def handle_cast(:show, state) do
  #   # deactivate() #TODO this will send :update_content and :reset_cursor again!!
  #   {:noreply, state}
  # end





  ## handle_cast



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
