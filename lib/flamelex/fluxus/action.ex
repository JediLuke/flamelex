defmodule Flamelex.Fluxus.Action do


  def fire(a) do
    IO.puts "DEPRECATE_MEEEE", ansi_color: :red
    :ok = GenServer.call(Flamelex.FluxusRadix, {:action, a})

    #NOTE: Ok, think about this for a sec...
    # EventBus.notify(%EventBus.Model.Event{
    #   id: UUID.uuid4(),
    #   topic: :general,
    #   data: {:action, a}
    # })

  end
end