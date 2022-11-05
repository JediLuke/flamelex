defmodule Flamelex.Fluxus.ActionListener do
    @moduledoc """
    This process listens to events on the :general topic, and if they're
    actions, makes stuff happen.
    """
    use GenServer
    require Logger
  
    def start_link(_args) do
      GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end
  
    def init(_args) do
      Logger.debug("#{__MODULE__} initializing...")
      EventBus.subscribe({__MODULE__, ["general"]})
      {:ok, %{}}
    end
  
    def process({:general = _topic, _id} = event_shadow) do
        event = EventBus.fetch_event(event_shadow)
        if not an_action?(event) do
            :ignore
        else
            %EventBus.Model.Event{id: _id, topic: :general, data: {:action, action}} = event
            radix_state = Flamelex.Fluxus.RadixStore.get()
            case Flamelex.Fluxus.RadixReducer.process(radix_state, action) do
                x when x in [:ignore, :ok] ->
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    #Logger.debug "#{__MODULE__} ignoring... #{inspect(%{action: action})}"
                    #Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
                    :ignore
                {:ok, ^radix_state} ->
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    #Logger.debug "#{__MODULE__} ignoring (no state-change)... #{inspect(%{radix_state: radix_state, action: action})}"
                    #Logger.debug "#{__MODULE__} ignoring (no state-change)..."
                    :ignore
                {:ok, new_radix_state} ->
                    #Logger.debug "#{__MODULE__} processed event, state changed..."
                    #Logger.debug "#{__MODULE__} processed event, state changed... #{inspect(%{radix_state: radix_state, action: action})}"
                    Flamelex.Fluxus.RadixStore.broadcast_update(new_radix_state)
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    {:ok, new_radix_state}
                {:error, reason} ->
                    Logger.error "Unable to process event `#{inspect event}`, reason: #{inspect reason}"
                    raise reason
            end
        end
    end

    defp an_action?(%{data: {:action, _action}}), do: true
    defp an_action?(_otherwise), do: false
  
end