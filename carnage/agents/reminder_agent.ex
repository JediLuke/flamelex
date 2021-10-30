defmodule Flamelex.Agent.Reminders do
  @moduledoc """
  This agent runs & checks for reminders.
  """
  use GenServer
  require Logger
  alias Flamelex.Structs.TidBit

  @default_reminder_time_in_minutes 15

  def start_link([] = default_params) do
    GenServer.start_link(__MODULE__, default_params)
  end

  # def snooze_reminder(reminder_uuid, time) do
  #   find_reminder(reminder_uuid)
  #   |> update_state()
  #   |> update_user_data()
  # end

  def pending_reminders() do
    GenServer.call(__MODULE__, :pending_reminders)
  end

  # changes tag from "reminder" to "ackd_reminder"
  def ack_reminder(r = %TidBit{}) do
    GenServer.cast(__MODULE__, {:ack_reminder, r})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(_params) do
    IO.puts "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, _initial_state = [], {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, state) do
    send self(), :check_reminders
    {:noreply, state}
  end

  @impl true
  def handle_call(:pending_reminders, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:ack_reminder, %TidBit{uuid: ack_uuid} = r}, state) do
    new_state = state |> Enum.reject(& &1.uuid == ack_uuid)
    :ok = ack_reminder_in_user_data_file(r)
    Logger.info "Reminder #{inspect r} has been acknowledged."
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:check_reminders, state) do
    # Logger.info("Checking reminders...")
    state =
      Utilities.Data.find(tags: "reminder") |> process_reminders(state)
    Process.send_after(self(), :check_reminders, :timer.seconds(10))
    {:noreply, state}
  end

  def handle_info({:reminder!, r}, state) do
    Logger.warn "REMINDING YOU ABOUT! - #{inspect r}"
    #TODO right now, schedule to remind me again (so I don't forget) - when it's acknowledged, this will stop
    Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
    {:noreply, state}
  end

  defp process_reminders([], state), do: state
  defp process_reminders([{_key, data} = r | rest], state) do
    case reminder_already_pending?(r, state) do
      true ->
        # Logger.info "Reminder was already pending. #{inspect r}"
        process_reminders(rest, state)
      false ->
        # we found a new reminder...
        case data["remind_me_datetime"] do
          nil ->
            Logger.error "Found a reminder #{inspect r} that didn't have a reminder time."
            state = set_up_reminder(r, state, @default_reminder_time_in_minutes)
            process_reminders(rest, state)
          _remind_me_datetime ->
            Logger.info "Found a new reminder! Setting up a reminder... #{inspect r}"
            state = set_up_reminder(r, state)
            process_reminders(rest, state)
        end
    end
  end

  defp reminder_already_pending?(r, state) when is_list(state) do
    state |> Enum.member?(r)
  end

  defp set_up_reminder({_key, _data} = r, state, time_in_minutes) do
    Process.send_after(self(), {:reminder!, r}, time_in_minutes * (60 * 1000))
    state ++ [r]
  end
  defp set_up_reminder({_key, data} = r, state) do
    now_utc = DateTime.utc_now()
    remind_me_datetime = data["remind_me_datetime"]
    {:ok, remind_me_utc, 0} = remind_me_datetime |> DateTime.from_iso8601()
    case DateTime.compare(remind_me_utc, now_utc) do
      future when future in [:gt] ->
        notify_delay_ms = DateTime.diff(remind_me_utc, DateTime.utc_now()) * 1000
        Process.send_after(self(), {:reminder!, r}, notify_delay_ms)
        state ++ [r]
      past_or_present when past_or_present in [:lt, :eq] ->
        Logger.warn "This reminder is in the past! #{inspect r}"
        Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
        state ++ [r]
    end
  end

  defp ack_reminder_in_user_data_file(r) do
    ackd_reminder = r |> TidBit.ack_reminder()
    Utilities.Data.replace_tidbit(r, ackd_reminder)
  end
end



  # this came out of GUI.Controller...

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
  #       notify_delay_ms = DateTime.diff(remind_me_utc, DateTime.utc_now()) * 1000
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

  # add a new buffer to the state's buffer_list
  # defp add_buffer(state, buf, f) do
  #   buf_frame = {buf: buf, frame: f}

  #   state
  #   |> Map.update!(:buffers, fn buf_list -> buf_list ++ [buf_frame] end)
  # end
