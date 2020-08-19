defmodule GUI.Controller do
  @moduledoc """
  This process, separate from Scenic itself, runs the GUI. It stacks
  buffers, handles updates, etc.
  """
  use GenServer
  require Logger
  alias Structs.Buffer


  def start_link([] = default_params) do
    GenServer.start_link(__MODULE__, default_params)
  end

  def register_new_buffer(args), do: GenServer.cast(__MODULE__, {:register_new_buffer, args})

  def show_fullscreen(buffer), do: GenServer.cast(__MODULE__, {:show_fullscreen, buffer})

  def fetch_active_buffer(), do: GenServer.call(__MODULE__, :fetch_active_buffer)

  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(_params) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    initial_state = %{
      active_buffer: nil,
      buffer_list: []
    }

    {:ok, initial_state, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, state) do
    # send self(), :check_reminders

    # GUI.Component.CommandBuffer.initialize() #NOTE: don't do this here, when the buffer comes up that does it

    Logger.info("#{__MODULE__} initialization complete.")
    {:noreply, state}
  end

  @impl true
  def handle_call(:fetch_active_buffer, _from, state) do
    {:reply, state.active_buffer, state}
  end


  # @impl true
  # def handle_cast({:register_new_buffer, [type: :text, content: c, action: 'OPEN_FULL_SCREEN'] = args}, %{
  #   buffer_list: [] # the case where we have no open buffers
  # } = state) do


  #   new_state =
  #     state
  #     |> Map.update!(:buffer_list, fn _b -> [1] end) #TODO have a buffer struct I guess...

  #   #TODO call Scenic GUI component process (registered to this topic/whatever) &
  #   GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: c]})

  #   {:noreply, new_state}
  # end

  @impl true
  def handle_cast({:show_fullscreen, %Buffer{} = buffer}, state) do

    # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

    new_state =
      state
      |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
      |> Map.update!(:active_buffer, fn _ab -> buffer end)

    # IO.puts "SENDING --- #{new_state.active_buffer.content}"
    GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    {:noreply, new_state}
  end


  # @impl true
  # def handle_info(:check_reminders, state) do
  #   # Logger.info("Checking reminders...")
  #   state =
  #     Utilities.Data.find(tags: "reminder") |> process_reminders(state)
  #   Process.send_after(self(), :check_reminders, :timer.seconds(10))
  #   {:noreply, state}
  # end

  # def handle_info({:reminder!, r}, state) do
  #   Logger.warn "REMINDING YOU ABOUT! - #{inspect r}"
  #   #TODO right now, schedule to remind me again (so I don't forget) - when it's acknowledged, this will stop
  #   Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
  #   {:noreply, state}
  # end

  # defp process_reminders([], state), do: state
  # defp process_reminders([{_key, data} = r | rest], state) do
  #   case reminder_already_pending?(r, state) do
  #     true ->
  #       # Logger.info "Reminder was already pending. #{inspect r}"
  #       process_reminders(rest, state)
  #     false ->
  #       # we found a new reminder...
  #       case data["remind_me_datetime"] do
  #         nil ->
  #           Logger.error "Found a reminder #{inspect r} that didn't have a reminder time."
  #           state = set_up_reminder(r, state, @default_reminder_time_in_minutes)
  #           process_reminders(rest, state)
  #         _remind_me_datetime ->
  #           Logger.info "Found a new reminder! Setting up a reminder... #{inspect r}"
  #           state = set_up_reminder(r, state)
  #           process_reminders(rest, state)
  #       end
  #   end
  # end

  # defp reminder_already_pending?(r, state) when is_list(state) do
  #   state |> Enum.member?(r)
  # end

  # defp set_up_reminder({_key, _data} = r, state, time_in_minutes) do
  #   Process.send_after(self(), {:reminder!, r}, time_in_minutes * (60 * 1000))
  #   state ++ [r]
  # end
  # defp set_up_reminder({_key, data} = r, state) do
  #   now_utc = DateTime.utc_now()
  #   remind_me_datetime = data["remind_me_datetime"]
  #   {:ok, remind_me_utc, 0} = remind_me_datetime |> DateTime.from_iso8601()
  #   case DateTime.compare(remind_me_utc, now_utc) do
  #     future when future in [:gt] ->
  #       notify_delay_ms = DateTime.diff(remind_me_utc, DateTime.utc_now()) * 1000 |> IO.inspect
  #       Process.send_after(self(), {:reminder!, r}, notify_delay_ms)
  #       state ++ [r]
  #     past_or_present when past_or_present in [:lt, :eq] ->
  #       Logger.warn "This reminder is in the past! #{inspect r}"
  #       Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
  #       state ++ [r]
  #   end
  # end

  # defp ack_reminder_in_user_data_file(r) do
  #   ackd_reminder = r |> TidBit.ack_reminder()
  #   Utilities.Data.replace_tidbit(r, ackd_reminder)
  # end
end
