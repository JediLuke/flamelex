defmodule Flamelex.Fluxus.RadixReducer do
  @moduledoc """
  The RootReducer for all flamelex actions.

  These pure-functions are called by ActionListener, to handle specific
  actions within the application. Every action that gets processed, is
  routed down to the sub-reducers, through this module. Every possible
  action, must also be declared inside this file.

  A reducer is a function that determines changes to an application's state.

  All the reducers in Flamelex.Fluxus (and this includes both action
  handlers, and user-input handlers) work the same way - they take in
  the application state, & an action, & return an updated state. They
  may also fire off side-effects along the way, including further actions.

  ```
  A reducer is a function that determines changes to an application's state.
  It uses the action it receives to determine this change. We have tools,
  like Redux, that help manage an application's state changes in a single
  store so that they behave consistently.
  ```
  https://css-tricks.com/understanding-how-reducers-are-used-in-redux/


  Here we have the function which `reduces` a radix_state and an action.

  Our main way of handling actions is simply to broadcast them on to the
  `:actions` broker, which will forward it to all the main Manager processes
  in turn (GUiManager, BufferManager, AgentManager, etc.)

  The reason for this is, what's going to happen is, say I send a command
  like `open_buffer` to open my journal. We spin up this action handler
  task - say that takes 2 seconds to run for some reason. If I send the
  same action again, another process will spin up. Eventually, they're
  both going to finish, and whoever is getting the results (FluxusRadix)
  is going to get 2 messages, and then have to handle the situation of
  dealing with double-processes of actions (yuck!)

  what we want to do instead is, the reducer broadcasts the message to
  the "actions" channel - all the managers are able to react to this event.
  """
  alias Flamelex.Fluxus.RadixState
  require Logger

  def process(%{layers: %{three: %{open_memex_popup_open?: true}}} = rdx, {:memex_aperi, :close}) do
    Flamelex.GUI.Layers.Layer3.Mutator.deactivate_popup(rdx)
  end

  def process(%{layers: %{three: %{start_new_memex_popup_open?: true}}} = rdx, {:memex_aperi, :close}) do
    Flamelex.GUI.Layers.Layer3.Mutator.deactivate_popup(rdx)
  end

  def process(%{layers: %{three: %{open_memex_popup_open?: true}}} = rdx, action) do
    Logger.warning "Ignoring action #{inspect action} cause we're in a popup state..."
    rdx
  end

  # def process(rdx, :open_kommander = action) do
  #   Flamelex.GUI.Component.Kommander.Reducer.process(rdx, action)
  # end

  # def process(rdx, :close_kommander = action) do
  #   Flamelex.GUI.Component.Kommander.Reducer.process(rdx, action)
  # end

  # def process(rdx, :execute_kommander = action) do
  #   Flamelex.GUI.Component.Kommander.Reducer.process(rdx, action)
  # end

  def process(rdx, {Flamelex.GUI.Component.Kommander, action}) do
    Flamelex.GUI.Component.Kommander.Reducer.process(rdx, action)
  end

  alias Flamelex.GUI.Component.RapidSelector

  def process(rdx, {:load_memex, %Memelex.Environment{} = env}) do
    # TODO when I eventually go multi-env, this may be a problem...

    rdx
    |> put_in([:memex, :active?], true)
    |> put_in([:memex, :env], env)
    |> RapidSelector.Reducer.process({:load_memex, env})
  end

  def process(rdx, {Flamelex.GUI.Component.TODOlist, action}) do
    Flamelex.GUI.Component.TODOlist.Reducer.process(rdx, action)
  end

  # for now hard code this redirect because we know it's going to be applied at the component level
  def process(rdx, {Flamelex.GUI.Component.TODOdetails.Reducer, action}) do
    rdx
    |> Flamelex.GUI.Component.TODOlist.Reducer.process(action)
    |> Flamelex.GUI.Component.TODOdetails.Reducer.process(action)
  end

  def process(rdx, :novum_memexi) do
    rdx
    |> Flamelex.GUI.Layers.Layer3.Mutator.activate_popup(:start_new_memex)
  end

  def process(rdx, :memex_aperi) do
    # %{rdx.layers.three.open_memex_popup_open? | true }
    Flamelex.GUI.Layers.Layer3.Mutator.activate_popup(rdx)
  end

  def process(rdx, {:reloaded_my_modz, _env}) do
    IO.puts "Hey cool man - should do something about reloading these mods hey!"
    :ignore
  end

  def process(
        %RadixState{layers: %{one: %{active_apps: [Flamelex.GUI.Component.HighCouncil]}}} = rdx,
        {Flamelex.GUI.Component.HighCouncil, action}
      ) do
    Flamelex.GUI.Component.HighCouncil.Reducer.process(rdx, action)
  end

  def process(rdx, {Flamelex.GUI.Component.TODOlist.Reducer, action}) do
    Flamelex.GUI.Component.TODOlist.Reducer.process(rdx, action)
  end

  def process(rdx, {:open_tidbit, %Memelex.TidBit{} = _t} = action) do
    Flamelex.GUI.Component.RapidSelector.Reducer.process(rdx, action)
  end

  def process(rdx, {Flamelex.GUI.Component.RapidSelector, action}) do
    Flamelex.GUI.Component.RapidSelector.Reducer.process(rdx, action)
  end

  def process(rdx, :show_agents) do
    Flamelex.GUI.Component.HighCouncil.Reducer.process(rdx, :show_agents)
  end

  def process(rdx, {Flamelex.GUI.Component.AgentHuddle, action}) do
    rdx
    |> Flamelex.GUI.Component.AgentHuddle.Reducer.process(action)
    # |> Flamelex.GUI.Component.HighCouncil.Reducer.process(action)
  end

  def process(rdx, {Flamelex.GUI.Component.QlxWrap, {:set_overlay, :window_manager}}) do
    # TODO do this in layer 3 as an overlay for whole app, or keep it local to QlxWrap? decide later!
    IO.puts "RADIX MANAGING WINDOW MODE"
    rdx
    |> Flamelex.GUI.Layers.Layer3.Mutator.set_overlay(:window_manager)
  end

  def process(rdx, {Flamelex.GUI.Component.QlxWrap, action}) do
    Logger.warn "got QLX wrap action..."
    # cant wrap {:action, a} here, it just gets too messy since not everything was notated this way
    Flamelex.GUI.Component.QlxWrap.Reducer.process(rdx, action)
  end

  # def process(rdx, {Flamelex.GUI.Component.QlxWrap, _buf, {:set_overlay, :window_manager}}) do
  #   # TODO do this in layer 3 as an overlay for whole app, or keep it local to QlxWrap? decide later!
  #   IO.puts "RADIX MANAGING WINDOW MODE"
  #   rdx
  #   |> Flamelex.GUI.Layers.Layer3.Mutator.set_overlay(:window_manager)
  # end

  def process(rdx, {Flamelex.GUI.Component.QlxWrap, buf, action}) do
    Flamelex.GUI.Component.QlxWrap.Reducer.process(rdx, buf, action)
  end

  def process(rdx, {Flamelex.Fluxus.Reducers.Projects, action}) do
    Flamelex.Fluxus.Reducers.Projects.process(rdx, action)
  end

  # these are actions coming from the Memelex application
  def process(rdx, {Flamelex.Fluxus.MemelexEventHandler, action}) do
    # broadcast an action that this happened?
    # IO.inspect(action, label: "this is the msg that bubbled up from memelex")

    # here the idea is that we pass it through the "memex pipeline" - all the apps which might care about this action
    rdx
    |> Flamelex.GUI.Component.RapidSelector.Reducer.process(action)
  end

  # def process(rdx_state, {:set_overlay, :window_manager}) do
  #   IO.puts "OVERLAY WINDOW MGR"
  #   :ignore
  # end

  # theoretically we dont need to handle things we dont know how to handle (because Wormhole will prevent a crash)
  # but it does make a lot of noise... sometimes it's nicer to just print the msg, but delete this before 1.0
  def process(rdx_state, action) do
    Logger.error("#{__MODULE__} unable to process action. #{inspect(action)}")
    :ignore
  end
end

# def process(rdx, {component, action}) when is_module(component) do
#   # Flamelex.GUI.Component.TODOdetails.Reducer.process(rdx, action)
#   raise "somehow you hit this experimental clause... but I like it - uncomment this raise and lets see what happens"
#   Module.concat(component, Reducer).process(rdx, action)
# end

# todo use_module would be better but the compiler hates it
# This clause is here to make it easier to route actions straight to the appropriate reducer,
# for the situations when we know (when we fire the action) which reducer should handle it
# def process(radix_state, {reducer, action}) when is_atom(reducer) do
#   # Instead of try catch, look in the module, see if there's a function called that.

#   # That could be cool, if we make all actions an actual function in the processor?? (in the end, this is cool but ultimately just pointless complication...
#   # but the idea _is_ cool, we would call MFA.apply(reducer, action, args) or something like that, and it would look up the function in the module and call it

#   # If that fails/doesn't work, we want to look up custom keymaps in the my_modz.ex (???)

#   # try do
#   # rescue
#   #   e in FunctionClauseError ->
#   #     {:error,
#   #      "#{__MODULE__} -- Reducer `#{inspect(reducer)}` could not match action: #{inspect(action)}"}
#   # end
#   reducer.process(radix_state, action)
# end

# If we try to open a TidBit and we're already in editor mode, don't switch to Memex mode
# def process(%{root: %{active_app: active_app}} = radix_state, {
#       Memelex.Fluxus.Reducers.TidbitReducer,
#       {:open_tidbit,
#        %{type: ["external", "textfile"], data: %{"filepath" => filepath}} = tidbit}
#     })
#     when active_app in [:desktop, :editor] do
#   QuillEx.Reducers.BufferReducer.process(
#     radix_state,
#     {:open_buffer, %{file: filepath, mode: {:vim, :normal}}}
#   )
# end

# this is a special case, we jump to a whole different scene
# def process(rdx, {WidgetWorkbench, :open}) do
#   # Flamelex.GUI.Component.TODOlist.Reducer.process(rdx, action)
#   # {:ok, _} = Scenic.ViewPort.set_root(scene.viewport, {WidgetWorkbench.Scene, %{}})
#   vp = Flamelex.GUI.RootScene.viewport()
#   {:ok, _} = Scenic.ViewPort.set_root(vp, {WidgetWorkbench.Scene, %{}})
#   :ignore
# end

# def app_is_active?(rdx_state, app) do
#   case rdx_state[:layers][:one][:active_apps] do
#     {^app, _args} ->
#       true

#     app_list when is_list(app_list) ->
#       Enum.reduce(app_list, false, fn {a, _}, acc ->
#         if a == app do
#           true
#         else
#           acc
#         end
#       end)
#   end
# end

# def update_active_app(rdx_state, app, merge: new_state) do
#   new_active_apps =
#     rdx_state[:layers][:one][:active_apps]
#     |> Enum.map(fn
#       {a, s} when a == app -> {a, s |> Map.merge(new_state)}
#       {a, s} -> {a, s}
#     end)

#   rdx_state
#   |> put_in([:layers, :one, :active_apps], new_active_apps)

#   # |> put_in([:layers, :one, :active_apps], [
#   #   {app, rdx_state[:layers][:one][:active_apps][app] |> Map.merge(new_state)}
#   # ])
# end
