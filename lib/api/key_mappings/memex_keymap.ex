defmodule Flamelex.Keymaps.Memex do
    alias Flamelex.Fluxus.Structs.RadixState
    use ScenicWidgets.ScenicEventsDefinitions
    alias Flamelex.Fluxus.Reducers.Memex, as: MemexReducer
    require Logger


    #TODO save the TidBit
    # def handle(%{root: %{active_app: :memex}, memex: memex} = radix_state, @enter_key) do

    def handle(%{root: %{active_app: :memex}, memex: memex} = radix_state, @tab_key) do
        # move the focus from the title, to the body
        case find_open_tidbit(memex) do
            [%{activate: :title, title: old_title} = tidbit] ->
                Flamelex.API.Buffer.modify(tidbit, %{activate: :body})
                :ok
            nil ->
                Logger.warn "No TidBits currently in edit mode."
                :ok
        end
    end

    def handle(%{root: %{active_app: :memex}, memex: memex} = radix_state, @shift_tab) do
        # move the focus from the title, to the body
        case find_open_tidbit(memex) do
            [%{activate: :body, title: old_title} = tidbit] ->
                Flamelex.API.Buffer.modify(tidbit, %{activate: :title})
                :ok
            nil ->
                Logger.warn "No open tidbits so we dont do anything"
                :ok
        end
    end

    def handle(%{root: %{active_app: :memex}, memex: memex} = radix_state, @meta_lowercase_s) do
        case find_open_tidbit(memex) do
            [t = %{uuid: tidbit_uuid}] ->
                Flamelex.Fluxus.action({MemexReducer, {:save_tidbit, %{tidbit_uuid: tidbit_uuid}}})
            nil ->
                Logger.warn "No open tidbits so we dont do anything"
                :ok
        end
    end

    # def handle(%{root: %{active_app: :memex}, kommander: %{hidden?: true}} = radix_state, input) when input in @valid_text_input_characters do
    def handle(%{root: %{active_app: :memex}, memex: memex}, input) when input in @valid_text_input_characters do
        case find_open_tidbit(memex) do
            [%{activate: :title, title: old_title} = tidbit] ->
                Flamelex.API.Buffer.modify(tidbit, %{
                    title: old_title <> key2string(input),
                    # cursor: Map.get(tidbit, :cursor, 0)+1 #NOTE: plus one...
                    cursor: tidbit.cursor+1
                })
                :ok
            [%{activate: :body, data: old_text} = tidbit] ->
                Flamelex.API.Buffer.modify(tidbit, %{
                    data: old_text <> key2string(input),
                    cursor: tidbit.cursor+1
                })
                :ok
            nil ->
                Logger.warn "No open tidbits so we dont do anything"
                :ok
            # otherwise ->
            #     IO.inspect otherwise, label: "wtf??"
            #     :ignore
        end
    end

    def handle(%{root: %{active_app: :memex}, memex: memex} = radix_state, @backspace_key) do
        case find_open_tidbit(memex) do
            [%{activate: :title, title: old_title} = tidbit] ->
                {remaining_string, _backspaced_letter} = String.split_at(old_title, -1)
                Flamelex.API.Buffer.modify(tidbit, %{
                    title: remaining_string,
                    cursor: (if tidbit.cursor-1 >= 0, do: tidbit.cursor-1, else: 0) # Don't go below 0 TODO also dont go higher than the number of characters lol
                })
                :ok
            [%{activate: :body, data: old_text} = tidbit] ->
                {remaining_string, _backspaced_letter} = String.split_at(old_text, -1)
                Flamelex.API.Buffer.modify(tidbit, %{
                    data: remaining_string,
                    cursor: (if tidbit.cursor-1 >= 0, do: tidbit.cursor-1, else: 0) # Don't go below 0 TODO also dont go higher than the number of characters lol
                })
                :ok
            nil ->
                Logger.warn "No open tidbits so we dont do anything"
                :ok
        end
    end

    # # def keymap(%{mode: :memex} = state, %{input: {:cursor_button, {:btn_left, 1, [], _coords}}} = input) do
    # def keymap(%{mode: :memex} = state, {:cursor_button, {:btn_left, 1, [], _coords}} = input) do
    #   {:execute_function, fn -> Flamelex.Fluxus.action({:memex, :new_random}) end}
    # end

    # # this is the function which gets called externally
    # def keymap(%{mode: :memex} = state, input) do
    #   # leader_binding_def(state, input)
    #   map(state)[input.input] #TODO YUCKKKKKK
    # end

    # #NOTE: Ok, this was an issue (sort-of?)
    # #
    # #      We can't run functions here, or else there will be side-effects
    # #      We can return a function which will be executed. If we just
    # #      put the code to 'fire action' straight in, instead of returning
    # #      that *as a function*, then that function will run as part of the
    # #      evaluation of this map (!! *all* functions in the map, every
    # #      possible action, will run/be fired!) - so we must always be
    # #      vigilant to wrap things in functions here

    # def map(_state) do
    #   %{
    #     # @escape_key => fn -> Flamelex.Fluxus.action({:switch_mode, :normal}) end #TODO lmao I think this is firing, not returning as a function!!
    #     @escape_key => {:execute_function, fn -> Flamelex.Fluxus.action({:switch_mode, :normal}) end} #TODO lmao I think this is firing, not returning as a function!!
    #   }
    # end
  
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
  



    #TODO in editor mode, save the buffer with leader-s

    # def handle(%{history: %{keystrokes: [@leader|_rest]}} = radix_state, input) do
    #     #   {:error, "UserInputHandler bottomed-out! No match was found."}
    #     Logger.debug "Handling... #{inspect input}"
    #     IO.puts "\n\nLAST KEY WAS SPACE\n\n"
    #     {:ok, radix_state}
    # end
  
  #   def handle(radix_state, input) when input in @valid_text_input_characters do
  #     Logger.warn "Unhandled input..."
  #     #REMINDER: We need to acknowledge the keystrokes in order to save
  #     # them into the keystroke history
  #     :ok
  # end


#   def handle(radix_state, input) do
#       Logger.warn "#{__MODULE__} Unhandled input... #{inspect input}"
#       #REMINDER: We need to acknowledge the keystrokes in order to save
#       # them into the keystroke history
#       :ok
#   end


  defp find_open_tidbit(%{story_river: %{open_tidbits: tidbit_list}}) do
      tidbit_list |> Enum.filter(& &1.mode == :edit) 
  end

end
  