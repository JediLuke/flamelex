defmodule Flamelex.Fluxus do
   @moduledoc """
   Flamelex.Fluxus implements the `flux` architecture pattern, of React.js
   fame, in Elixir/Scenic. This module provides the interface to that
   functionality.

   ### background

   https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

   ### prior art

   https://medium.com/grandcentrix/state-management-with-phoenix-liveview-and-liveex-f53f8f1ec4d7
   """
   require Logger
  
   # called to fire off an action
   def action(a) do
      EventBus.notify(%EventBus.Model.Event{
         id: UUID.uuid4(),
         topic: :general,
         data: {:action, a}
      })
   end

   # declaring means we get the results back - this function also
   # filters those results to just the ones from ActionListener
   def declare(a) do
      with {:ok, results} <- do_declare(a) do
         [final_radix_state] =
            Enum.reduce(results, [], fn
               {Flamelex.Fluxus.ActionListener, {:ok, new_radix_state}}, acc ->
                  acc ++ [new_radix_state]
               {Flamelex.Fluxus.InputListener, _res}, acc ->
               acc
            end)

         final_radix_state
      end
   end


   def do_declare(a) do
      {:ok, EventBus.declare(%EventBus.Model.Event{
         id: UUID.uuid4(),
         topic: :general,
         data: {:action, a}
      })}
   end

  # called to register user-input with the Fluxus system - Scenic MUST
  # forward input to Fluxus if it wants to be processed that way (input
  # might be captured & processed "locally" by a component, which could
  # then trigger an action... however if Scenic passes input through to
  # Fluxus, then it opens up the possibility of having things like Vim
  # keymaps that exist at a higher level than just a Scenic component)
  @doc """
  This function is called to channel all user input, e.g. keypresses,
  through the FluxusRadix, where they can be converted into actions.

  This function handles user input. All input from the entire GUI gets
  routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

  We use the RadixState (which includes global variables such as which
  mode we are in, the input history [to allow chaining of keystrokes\] etc),
  as well as the input itself, to compute the new state.

  The effect of most user input will be either to ignore it, or to dispatch
  an action - this is achieved by sending a new msg to the FluxusRadix, which
  will in turn be handled by spinning up a new Task process to handle it.






    ##TODO it's simpler to route these different right now.
    # call Flamelex.Fluxus.UserInput.

    # This is an example of the "state-centered" approach - we keep
    # wanting to store things in the scene - maybe I should just put everything
    # in here lol

    # The whole idea of 'fluxus' is to seperate out the state of your
    # application, from the state of your Scenic GUI processes

    #TODO this is one area of quandary - either I spin up a new process
    # to handle everything (nice security), but then I have to wait here
    # for a callback. Or, if I don't wait, then I have to give up my
    # ability to mutate the scene here.

    # Maybe how this should work is - instead of messaging a GenServer
    # which holds the root state, we just start a process, which fetches
    # a copy of the root state inside itself




  # @impl Scenic.Scene
  # def handle_event( {:click, :btn}, _, %{assigns: %{count: count}} = scene ) do
  #   count = count + 1

  #   # modify the graph to show the current click count
  #   graph =
  #     graph()
  #     |> Scenic.Graph.modify(:count, &text(&1, "Count: " <> inspect(count)))

  #   # update the count and push the modified graph
  #   scene =
  #     scene
  #     |> assign( count: count )
  #     |> push_graph( graph )

  #   # return the updated scene
  #   { :noreply, scene }
  # end

  # # handle all other (not-ignored) input...
  # def handle_event(input, _context, scene) do
  #   IO.puts "SOME NON IGNORED INPUT 
  #   # Flamelex.Fluxus.handle_user_input(input)
  #   {:noreply, scene}
  # end



  """
  def input(ii) do
    EventBus.notify(%EventBus.Model.Event{
      id: UUID.uuid4(),
      topic: :general,
      data: {:input, ii}
    })
  end

end
