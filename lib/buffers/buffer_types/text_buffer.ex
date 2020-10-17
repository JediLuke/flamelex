defmodule Flamelex.Buffer.Text do
  @moduledoc """
  A buffer to hold & manipulate text.
  """
  # use Flamelex.BufferBehaviour
  use GenServer, restart: :temporary
  require Logger
  alias Flamelex.Utilities.ProcessRegistry

  def start_link(params) do
    name = ProcessRegistry.via_tuple(gen_tag(params))
    GenServer.start_link(__MODULE__, params, name: name)
  end

  def gen_tag(%{from_file: name}) do
    {:buffer, name}
  end

  @doc """
  All Buffers essentially start the same way.
  """
  @impl GenServer
  def init(%{from_file: _filepath, open_in_gui?: true} = params) do
    Logger.debug "#{__MODULE__} initializing... params: #{inspect params}"
    {:ok, params, {:continue, :open_file_on_disk}}
  end

  @impl GenServer
  def handle_continue(:open_file_on_disk, %{from_file: filepath, open_in_gui?: true} = params) do

    {:ok, file_contents} = File.read(filepath)

    new_buf = %{
      name: filepath,
      data: file_contents,
      unsaved_changes?: false
    }

    send params.after_boot_callback, {self(), :successfully_opened, filepath, {:buffer, filepath}}

    {:noreply, new_buf}
  end

  @impl GenServer
  def handle_call(:read_contents, _from, state) do
    {:reply, state.data, state}
  end

  @impl GenServer
  def handle_call({:modify, {:insert, new_text, insertion_site}}, _from, state) do

    insert_text_function =
        fn string ->
          {before_split, after_split} = string |> String.split_at(insertion_site)
          before_split <> new_text <> after_split
        end

    new_state =
        state
        |> Map.update!(:data, insert_text_function)
        |> Map.put(:unsaved_changes?, true)

    #TODO make the modifications appear in GUI
    #   Flamelex.GUI.Controller.show_fullscreen(new_state)
    {:reply, :ok, new_state}
  end

  def handle_call(:save, _from, state) do

    {:ok, file} = File.open(state.name, [:write])
    IO.binwrite(file, state.data)
    :ok = File.close(file)

    new_state =
      state
      |> Map.put(:unsaved_changes?, false)

    {:reply, :ok, new_state}
  end

  def handle_cast(:close, state) do
    if state.unsaved_changes? do
      raise "need to be able to interact with the user here I guess..."
    else
      {:stop, :normal, state}
    end
  end



  # def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  # def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
  # def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
  # def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
  # def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)




  # def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :text} = state) do
  #   state = %{state|text: state.text <> letter}
  #   GUI.Component.Note.append_text(scenic_component_pid, :text, state)
  #   {:noreply, state}
  # end

  # def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
  #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
  #   new_state = %{state|focus: :text}
  #   {:noreply, new_state}
  # end

  # def handle_cast(:save_and_close, state) do
  #   DataFile.read()
  #     |> Map.merge(%{
  #          state.uuid => %{
  #            title: state.title,
  #            text: state.text,
  #            datetime_utc: DateTime.utc_now(),
  #            #TODO hash entire contents
  #            #TODO handle timezones
  #            tags: ["note"]
  #          },
  #        })
  #     |> DataFile.write()

  #   GUI.Scene.Root.action({:active_buffer, :note, 'CLOSE_NOTE_BUFFER'})
  #   {:noreply, state}
  # end

  # def handle_cast(:tab_key_pressed, %{focus: :text} = state) do
  #   Logger.warn "Text area doesn't handle tab character just yet..."
  #   {:noreply, state}
  # end

  # def handle_cast(:reverse_tab, %{focus: :text} = state) do
  #   Logger.warn "YES we got a shift+Tab in text though" #THIS WORKS!
  #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'})
  #   new_state = %{state|focus: :title}
  #   {:noreply, new_state}
  # end

end
