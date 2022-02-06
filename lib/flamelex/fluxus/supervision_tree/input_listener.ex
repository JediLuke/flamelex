defmodule Flamelex.Fluxus.InputListener do
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
        if not user_input?(event) do
            :ignore
        else
            %EventBus.Model.Event{id: _id, topic: :general, data: {:input, input}} = event
            radix_state = Flamelex.Fluxus.RadixStore.get() #TODO lock the store?
            case Flamelex.Fluxus.RadixUserInputHandler.handle(radix_state, input) do
                x when x in [:ignore, :ok] ->
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    Logger.debug "#{__MODULE__} ignoring... #{inspect(%{input: input})}"
                    #Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
                    :ignore
                {:ok, ^radix_state} ->
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    #Logger.debug "#{__MODULE__} ignoring (no state-change)... #{inspect(%{radix_state: radix_state, action: action})}"
                    Logger.debug "#{__MODULE__} ignoring (no state-change)..."
                    :ignore
                {:ok, new_radix_state} ->
                    Logger.debug "#{__MODULE__} processed event, state changed..."
                    #Logger.debug "#{__MODULE__} processed event, state changed... #{inspect(%{radix_state: radix_state, action: action})}"
                    Flamelex.Fluxus.RadixStore.put(new_radix_state)
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                    :ok
                {:error, reason} ->
                    Logger.error "Unable to process event `#{inspect event}`, reason: #{inspect reason}"
                    raise reason
            end
        end
    end

    defp user_input?(%{data: {:input, _input}}), do: true
    defp user_input?(_otherwise), do: false
  
end