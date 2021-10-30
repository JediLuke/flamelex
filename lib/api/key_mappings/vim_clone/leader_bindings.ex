defmodule Flamelex.API.KeyMappings.VimClone.LeaderBindings do
  alias Flamelex.Fluxus.Structs.RadixState
  use Flamelex.GUI.ScenicEventsDefinitions







  # this is the function which gets called externally
  def keymap(%RadixState{mode: :normal} = state, input) do
    # leader_binding_def(state, input)
    map(state)[input]
  end


  def map(_state) do
  %{
    # @lowercase_j => {:apply_mfa, {Flamelex.API.Journal, :now, []}},
    @lowercase_k => {:apply_mfa, {Flamelex.API.Kommander, :show, []}},
    # @lowercase_t => {:apply_mfa, {Flamelex.API.Memex.TiddlyWiki, :open, []}}, #TODO Memex.open_catalog()
    @lowercase_s => {:apply_mfa, {Flamelex.Buffer, :save, []}},
    #TODO these mappings are here for testing purposes, so make sure that leader commands are working as expected
    @lowercase_x => {:execute_function, fn -> raise "intentionally raising! little x" end},
    @uppercase_X => {:execute_function, fn -> raise "intentionally raising! big X" end}
  }
  end

  # def leader_binding_def(_state, @lowercase_j) do
  #   {:apply_mfa, {Flamelex.API.Journal, :now, []}}
  # end

  # # def leader_binding_def(_state, @lowercase_t) do
  # #   {:apply_mfa, {Flamelex.API.Memex.TiddlyWiki, :open, []}} #TODO Memex.open_catalog()
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
