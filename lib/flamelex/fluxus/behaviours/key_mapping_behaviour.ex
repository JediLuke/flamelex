defmodule Flamelex.Fluxux.KeyMappingBehaviour do
  @moduledoc """
  Defines the interface for a key-mapping.
  """
  alias Flamelex.Fluxus.Structs.RadixState
  require Logger


  defmacro __using__(_params) do
    quote do

      use Flamelex.ProjectAliases
      use Flamelex.GUI.ScenicEventsDefinitions
      alias Flamelex.Fluxus.Structs.RadixState
      require Logger


      #REMINDER: including this @behaviour in the __using__ macro here means
      #          that any module which calls `use This.Behaviour.Module`
      #          must implement all the callbacks defined in *this* module
      @behaviour Flamelex.Fluxux.KeyMappingBehaviour


      # this list of scenic events, we just want to totally ignore as input
      @list_of_ignorable_events [
          :viewport_enter,
          :viewport_exit
      ]


      @doc """
      This function is called by FluxusRadix to handle any user input.

      It in turn calls some of the functions which the module using this
      KeyMappingBehaviour has implemented, e.g. keymap/1
      """
      def lookup(_radix_state, {ignorable_event, _coords})
        when ignorable_event in @list_of_ignorable_events do
          :ignore_input
      end

      #TODO this isn't very clean, but gets the job done... ideally we want
      #     a consistent way to lookup the keymap though...
      def lookup(%RadixState{mode: :insert} = radix_state, input) do
        keymap(radix_state, input)
      end

      def lookup(%RadixState{mode: :command} = radix_state, input) do
        keymap(radix_state, input)
      end

      def lookup(radix_state, input) do
        #TODO look up active buffer here & use it to decipher keystrokes??
        try do
          if radix_state |> last_keystroke_was_leader?() do
            leader_keybindings(radix_state)[input]
          else
            ##TODO get the active buffer & pass it in??
            #NOTE: This cute little hack allows keymap to either  return
            #      the actions directly, or return a map that we contains
            #      the lookup we're interested in
            # case keymap(radix_state) do
            #   m when is_map(m) ->
            #       IO.puts "WELL I GUESS ITS A MAP??? #{inspect m, pretty: true}"
            #       m[input]
            #   otherwise ->
            #       IO.puts "YES ITS OTHERWISE #{inspect otherwise}"
            #       otherwise
            # end
            keymap(radix_state)[input]
          end
        rescue
          _e in FunctionClauseError ->
                  context = %{radix_state: radix_state, input: input}

                  error_msg = ~s(#{__MODULE__} failed to process some input due to a FunctionClauseError.

                  Most likely this KeyMapping module did not have a function
                  implemented which pattern-matched on this input.

                  context: #{inspect context})

                  Logger.error error_msg
                  :ignore_input
        end
      end

      defp last_keystroke_was_leader?(radix_state) do
        leader() != :not_defined
          and
        radix_state |> RadixState.last_keystroke() == leader()
      end
    end
  end



  @doc """
  For now, each KeyMapping must define a leader function.

  The leader key in vim lets you do custom keymaps, it's pretty useful.

  If you don't want your KeyMapping to have leader key functionality, then
  for now, just have it return `:not_defined`, and all the leader-key code
  will be ignored.
  """
  @callback leader() :: tuple() | :not_defined

  @doc """
  This function returns a map, which contains the direct lookups between
  keystroke inputs (potentially, pattern-matched on differend RadixState's,
  but still a one-to-one mapping) and actions.

  If a key must fire off multiple actions, it can return a list of those
  actions - but the function itself returns a map.
  """
  @callback keymap(map()) :: map()


  @doc """
  If you want custom leader keybindings, put them in this map.
  """
  @callback leader_keybindings(map()) :: map() #TODO this should be a %RadixState{} typespec


end
