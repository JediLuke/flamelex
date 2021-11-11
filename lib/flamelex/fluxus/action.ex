defmodule Flamelex.Fluxus.Action do

    ## this module will eventually give me a nicer interface than Flamelex.Fluxus

    # the problem with that module is that it's recursive - inputs, end up
    # calling itself again to handle actions - which gets confusing
    # nicer to just have each input, go through & fire an action
  def fire(a) do
    :ok = GenServer.call(Flamelex.FluxusRadix, {:action, a})
  end
end