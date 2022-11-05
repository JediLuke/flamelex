defmodule Flamelex.GUI.Layer.Behaviour do
    #TODO document all this lol

    # take in the radix_state and return a derived state which describes the layer
    @callback calc_state(map()) :: map()

    # take in the layer_state and return the graph describing the layer
    @callback render(map()) :: %Scenic.Graph{}
    
end