defmodule Flamelex.API.KeyMappings.Memex do
    alias Flamelex.Fluxus.Structs.RadixState
    use ScenicWidgets.ScenicEventsDefinitions

    # def keymap(%RadixState{mode: :memex} = state, %{input: {:cursor_button, {:btn_left, 1, [], _coords}}} = input) do
    def keymap(%RadixState{mode: :memex} = state, {:cursor_button, {:btn_left, 1, [], _coords}} = input) do
      {:execute_function, fn -> Flamelex.Fluxus.Action.fire({:memex, :new_random}) end}
    end
  
    # this is the function which gets called externally
    def keymap(%RadixState{mode: :memex} = state, input) do
      # leader_binding_def(state, input)
      map(state)[input.input] #TODO YUCKKKKKK
    end
  
    #NOTE: Ok, this was an issue (sort-of?)
    #
    #      We can't run functions here, or else there will be side-effects
    #      We can return a function which will be executed. If we just
    #      put the code to 'fire action' straight in, instead of returning
    #      that *as a function*, then that function will run as part of the
    #      evaluation of this map (!! *all* functions in the map, every
    #      possible action, will run/be fired!) - so we must always be
    #      vigilant to wrap things in functions here

    def map(_state) do
      %{
        # @escape_key => fn -> Flamelex.Fluxus.Action.fire({:switch_mode, :normal}) end #TODO lmao I think this is firing, not returning as a function!!
        @escape_key => {:execute_function, fn -> Flamelex.Fluxus.Action.fire({:switch_mode, :normal}) end} #TODO lmao I think this is firing, not returning as a function!!
      }
    end
  
    # def map(_state) do
    # %{
    #   # @lowercase_j => {:apply_mfa, {Flamelex.API.Journal, :now, []}},
    #   @lowercase_k => {:apply_mfa, {Flamelex.API.Kommander, :show, []}},
    #   # @lowercase_t => {:apply_mfa, {Flamelex.API.MemexWrap.TiddlyWiki, :open, []}}, #TODO MemexWrap.open_catalog()
    #   @lowercase_s => {:apply_mfa, {Flamelex.Buffer, :save, []}},
    #   #TODO these mappings are here for testing purposes, so make sure that leader commands are working as expected
    #   @lowercase_x => {:execute_function, fn -> raise "intentionally raising! little x" end},
    #   @uppercase_X => {:execute_function, fn -> raise "intentionally raising! big X" end}
    # }
    # end
  
    # def leader_binding_def(_state, @lowercase_j) do
    #   {:apply_mfa, {Flamelex.API.Journal, :now, []}}
    # end
  
    # # def leader_binding_def(_state, @lowercase_t) do
    # #   {:apply_mfa, {Flamelex.API.MemexWrap.TiddlyWiki, :open, []}} #TODO MemexWrap.open_catalog()
    # # end
  
    # def leader_binding_def(_state, @lowercase_k) do
    #   {:apply_mfa, {Flamelex.API.Kommander, :show, []}}
    # end
  
    # def leader_binding_def(_state, @lowercase_s) do
    #   {:apply_mfa, {Flamelex.Buffer, :save, []}} #TODO this just savs the, default? active? Buffer
    # end
  
    # # these are here for testing purposes...
  
    # def leader_binding_def(_state, @lowercase_x) do
    #   {:execute_function, fn -> raise "intentionally raising! little x" end}
    # end
  
    # def leader_binding_def(_state, @uppercase_X) do
    #   {:execute_function, fn -> raise "intentionally raising! big X" end}
    # end
  
  end
  