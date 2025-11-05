defmodule Flamelex.Fluxus.MemelexEventHandler do
  @moduledoc """
  This is where Flamelex is able to handle events from Memelex.
  """
  alias Flamelex.GUI.Component.TODOdetails
  alias Flamelex.GUI.Component.RapidSelector
  require Logger

  def handle(rdx, {:loaded_memex, %Memelex.Environment{} = env}) do
    [{:load_memex, env}]
  end

  def handle(rdx, :show_todos) do
    [{Flamelex.GUI.Component.TODOlist, :show_todos}]
  end

  # def handle(rdx, {:open_tidbit, t}) do
  #   # [{RapidSelector.Reducer, {:open_tidbit, t}}]
  #   {:open_tidbit, t}
  # end

  def handle(rdx, :show_agents) do
    IO.puts("show the agent for realsies, from flamelex")
    # rdx
    # :ignore
    # []
    [:show_agents]
    # [{TODOlist.Reducer, :show_agents}]
  end

  # def handle(rdx, {:reloaded_my_modz, env}) do
  #   [{:reloaded_my_modz, env}]
  # end

  # def handle(rdx, {:tidbit_saved, t}) do
  #   IO.puts "flamelex got alerted to a tidbit saved #{inspect t}"
  #   # IO.inspect(t)
  #   # this is the situation where splitting the state up makes sense...
  #   # it's more logical I think to want to broadcast out "this got saved, update if you have to"
  #   # rather than knowing how to change the god state (maybe multiple apps get affected) to reflect the change

  #   # cool pseudocode though would be, for all the apps in :apps, get their component reducer fn,
  #   # call it with this tidbit & event, and then update the state with the result

  #   [
  #     # {TODOlist.Reducer, {:refresh_tidbit, t}},
  #     # {TODOdetails.Reducer, {:set_mode, :view}},
  #     # {TODOdetails.Reducer, {:refresh_tidbit, t}}
  #     {__MODULE__, {:tidbit_saved, t}}
  #     # {RapidSelector.Reducer, {:refresh_tidbit, t}}
  #   ]
  # end

  def handle(_rdx, {:tidbit_saved, %Memelex.TidBit{} = t} = a) do
    # TODO/NOTE here it feels natural to broadcast out on a TidBit channel, rather than using actions?
    # but then again, why bypass our beautiful centrally managed action system...

    # call radix store, let that know -> this is basically same as throwing an action...

    # here I'm gonna do something crazy & broadcast an event over a TidBit channel :D
    # Flamelex.Lib.Utils.PubSub.broadcast(
    #   topic: {:memelex, :tidbit, t.uuid},
    #   msg: {:tidbit_saved, t}
    # )

    # my instinct here is still to broadcast... then the components have to handle it?
    # this way I can just force a refresh anyway? but like what if it's a new

    # :ignore
    # [{__MODULE__, mmlx_event}]
    # [mmlx_event]

    IO.puts "GOT MEMELEX ACTION TIDBIT SVED"

    Logger.debug "Flamelex is handling a Memelex action: #{inspect a}"

    [
      {TODOdetails.Reducer, {:refresh_tidbit, t}},
      # {HighCouncil.Reducer, {:refresh_tidbit, t}},
      {Flamelex.GUI.Component.RapidSelector, {:refresh_tidbit, t}},
      {Flamelex.GUI.Component.AgentHuddle, {:refresh_tidbit, t}},
    ]
  end

  def handle(_rdx, {:reloaded_my_modz, _memex}) do
    :ignore
  end

  def handle(_rdx, mmlx_event) do
    # pass memelex events along to be treated as actions by Fluxus (cause we trust Memelex, right !>?)
    Logger.warning "implicitely handling a MODUILE Memelex event as a Flamelex action..."
    [{__MODULE__, mmlx_event}]
    # [mmlx_event]
  end

  # def handle(_rdx, mmlx_event) do
  #   # pass memelex events along to be treated as actions by Fluxus (cause we trust Memelex, right !>?)
  #   Logger.warning "implicitely handling a Memelex event as a Flamelex action..."
  #   # [{__MODULE__, mmlx_event}]
  #   [mmlx_event]
  # end
end


# def process(radix_state, {:open_text_snippet, %{data: %{"file_path" => file_path}}}) do
#   # raise "here we should open it in sublime or gedit"
#   # temporarily allow this since flamelex can't open files nicely yet and I still want to be able to do this from within Flamelex
#   Memelex.Utils.ToolBag.open_gedit(file_path)
#   :ignore
# end

# def add_gui_args(t) do
#   Map.merge(t, %{
#     gui: %{
#       mode: :normal,
#       focus: :title,
#       cursors: %{
#         # TODO we need to ensure no titles contain newoine chars, or if we do, then we need to allow ourselves to handle it - probably we should be able to just say "put the cursor in final position" & let TextPad figure it out...
#         # we need the +1 because a string of length zero is still position 1 in our editor
#         title: %{line: 1, col: String.length(t.title) + 1},
#         body: %{line: 1, col: 1}
#       }
#     }
#   })
# end

# def process(rdx, {:open_tidbit, t}) do
#   [{RapidSelector.Reducer, {:open_tidbit, t}}]
# end

# raise "Flamelex not handling the event to open a TidBit yet"
# {:ok, new_memex_state} =
#   Memelex.Fluxus.Reducers.TidbitReducer.process(memex_state, {:open_tidbit, t})

# {:ok, radix_state, new_memex_state}

# TODO eventually dont return a changes radix state, return a list of actions
# def process(rdx, :show_todos) do
#   # DONT change the TODOlist state here since we are just switching to it!
#   # OR alternatively, why not refresh it?? Plus we need to initialize it _somewhere_ !
#   # If we don't do it here then there's a chance we will switch back and the data will be stale
#   rdx
#   |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:full_screen)
#   |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist])
#   |> Flamelex.Fluxus.TODOsMutators.refresh_todo_list()
# end

# def process(radix_state, {:reloaded_my_modz, t}) do
#   # dunno what to do about this for now
#   :ignore
# end

# def process(radix_state, {:tidbit_saved, t}) do
#   # todo_list = Memelex.My.TODOs.all()
#   IO.puts("DO SOMETHING")
#   radix_state
#   # |> maybe_update_todos({:tidbit_saved, t})

#   # if get_in(radix_state, [:layers, :one, :active_apps]) == {Flamelex.GUI.Component.TODOlist, _todo_list} do
#   #   Logger.info("TODOlist is active, updating...")
#   #   radix_state
#   #   |> put_in([:layers, :one, :active_apps], {Flamelex.GUI.Component.TODOlist, Memelex.My.TODOs.all()})
#   # else
#   #   Logger.info("TODOlist is not active, ignoring...")
#   #   radix_state
#   # end

#   # radix_state
#   # |> put_in([:layers, :one, :active_apps], {Flamelex.GUI.Component.TODOlist, todo_list})
# end

# defp maybe_update_todos(
#        %{layers: %{one: %{active_app: {Flamelex.GUI.Component.TODOlist, todo_list}}}} =
#          radix_state,
#        {:tidbit_saved, t}
#      ) do
#   if Enum.member?(Enum.map(todo_list, & &1.uuid), t.uuid) do
#     Logger.info("TODOlist is active, updating...")

#     radix_state
#     |> put_in(
#       [:layers, :one, :active_apps],
#       [{Flamelex.GUI.Component.TODOlist, Memelex.My.TODOs.all()}]
#     )
#   else
#     # Logger.info("TODOlist is not active, ignoring...")
#     radix_state
#   end
# end

# defp maybe_update_todos(
#        %{layers: %{one: %{active_apps: [{Flamelex.GUI.Component.TODOlist, todo_list}]}}} =
#          radix_state,
#        {:tidbit_saved, _t}
#      ) do
#   # if Enum.member?(Enum.map(todo_list, & &1.uuid), t.uuid) do
#   #   Logger.info("TODOlist is active, updating...")

#   #   radix_state
#   #   |> put_in(
#   #     [:layers, :one, :active_apps],
#   #     [{Flamelex.GUI.Component.TODOlist, Memelex.My.TODOs.all()}]
#   #   )
#   # else
#   #   # Logger.info("TODOlist is not active, ignoring...")
#   #   radix_state
#   # end
#   radix_state
#   |> put_in(
#     [:layers, :one, :active_apps],
#     [{Flamelex.GUI.Component.TODOlist, Memelex.My.TODOs.all()}]
#   )
# end

# defp maybe_update_todos(
#        %{
#          layers: %{
#            one: %{
#              active_apps: [
#                {Flamelex.GUI.Component.TODOlist, %{list: todo_list} = todo_app_state},
#                {Flamelex.GUI.Component.TODOdetails, selected_todo}
#              ]
#            }
#          }
#        } = radix_state,
#        {:tidbit_saved, t}
#      ) do
#   # if Enum.member?(Enum.map(todo_list, & &1.uuid), t.uuid) do
#   #   Logger.info("TODOlist is active, updating...")

#   if t.uuid == selected_todo.uuid do
#     radix_state
#     |> put_in(
#       [:layers, :one, :active_apps],
#       [
#         {Flamelex.GUI.Component.TODOlist,
#          Map.merge(todo_app_state, %{list: Memelex.My.TODOs.all()})},
#         {Flamelex.GUI.Component.TODOdetails, t}
#       ]
#     )
#   else
#     radix_state
#     |> put_in(
#       [:layers, :one, :active_apps],
#       [
#         {Flamelex.GUI.Component.TODOlist,
#          Map.merge(todo_app_state, %{list: Memelex.My.TODOs.all()})},
#         {Flamelex.GUI.Component.TODOdetails, selected_todo}
#       ]
#     )
#   end

#   # radix_state
#   # |> put_in(
#   #   [:layers, :one, :active_apps],
#   #   {Flamelex.GUI.Component.TODOlist, Memelex.My.TODOs.all()}
#   # )
#   # else
#   #   # Logger.info("TODOlist is not active, ignoring...")
#   #   radix_state
#   # end
# end

# def process(_rdx, unknown_event) do
#   IO.puts("GOT #{inspect(unknown_event)}")
#   :ignore
# end


# def process(
#       radix_state,
#       memex_state,
#       {:reloaded_my_modz, %{env_modz_module: mod} = new_memex_env}
#     )
#     when is_atom(mod) do
#   IO.puts("YES YES RELOADED MY MODZ")

#   # raise "where are we..."

#   new_radix_state =
#     radix_state
#     |> put_in([:memex, :env], new_memex_env)
#     |> Flamelex.Fluxus.Structs.RadixState.calc_menu_map()

#   {:ok, new_radix_state, memex_state}
# end

# def process(radix_state, memex_state, :show_agents) do
#   Memelex.Utils.AgentUtils.show_agents()
#   {:ok, radix_state, memex_state}
# end

# def process(_radix_state, _memex_state, event) do
#   # Flamelex.Keymaps.Kommander |> process_with_rescue(radix_state, input)
#   Logger.info("Got MemelexEvent: #{inspect(event)}")
#   :ignore
# end

# def process(%{root: %{active_app: :desktop}} = radix_state, input) do
#   Flamelex.Keymaps.Desktop |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :editor}} = radix_state, input) do
#   # TODO route this to QuillEx
#   # QuillEx.Fluxus.input(input)
#   Flamelex.Keymaps.Editor |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :memex}} = radix_state, input) do
#   # fire it off to Memelex, they can worry about this one...
#   Memelex.Fluxus.input(input)
#   :ignore
# end

# # ------

# defp process_with_rescue(reducer, radix_state, input) do
#   try do
#     reducer.process(radix_state, input)
#   rescue
#     FunctionClauseError ->
#       Logger.warn("input: #{inspect(input)} not handled by Reducer `#{inspect(reducer)}`")
#       # TODO should we still record this input??
#       # {:ok, radix_state |> record_input(input)}
#       :ignore
#   else
#     :ok ->
#       {:ok, radix_state |> record_input(input)}

#     # TODO I don't think we should allow any InputHandler to return a RadixState, since we dont broadcast out from them...
#     # {:ok, new_radix_state} ->
#     #    {:ok, new_radix_state |> record_input(input)}
#     :ignore ->
#       :ignore

#     :error ->
#       :error
#   end
# end

# defp record_input(radix_state, {:key, {key, @key_pressed, []}} = input)
#      when input in @valid_text_input_characters do
#   # Logger.debug "-- Recording INPUT: #{inspect key}"
#   # NOTE: We store the latest keystroke at the front of the list, not the back
#   radix_state
#   |> put_in([:history, :keystrokes], radix_state.history.keystrokes |> List.insert_at(0, input))
# end

# defp record_input(radix_state, input) do
#   # Logger.debug "NOT recording: #{inspect input} as input..."
#   radix_state
# end
