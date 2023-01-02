defmodule Flamelex.Fluxus.UserInputListener do
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
            case Flamelex.Fluxus.UserInputHandler.process(radix_state, input) do
                :ignore ->
                    #Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                {:ok, ^radix_state} ->
                    #Logger.debug "#{__MODULE__} ignoring (no state-change)..."
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
                {:ok, new_radix_state} ->
                    #Logger.debug "#{__MODULE__} processed event, state changed..."
                    Flamelex.Fluxus.RadixStore.put(new_radix_state)
                    EventBus.mark_as_completed({__MODULE__, event_shadow})
            end
        end
    end

    defp user_input?(%{data: {:input, _input}}), do: true
    defp user_input?(_otherwise), do: false
  
end