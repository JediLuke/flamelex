defmodule GUI.Reducer.NewFrame do
  @moduledoc """
  Contains module attribute definitions of all the Scenic input events.
  """


  #TODO do we even need mcros here (which get us the nice pattern match), can we just use import??

  @doc false
  defmacro __using__(_opts) do
    quote do

      def process({state, graph}, {'NEW_FRAME', [type: :text, content: content]}) do

        IO.puts "getting nre grame, content: #{inspect content}"

        new_graph =
          graph
          |> GUI.Utilities.Draw.text(content) #TODO update the correct buffer GUI process, & do it from within that buffer itself (high-five!)

        {state, new_graph} #TODO do we update the state??
      end

    end
  end
end
