defmodule Flamelex.OmegaMaster do
  @moduledoc """
  The OmegaMaster holds the highest-level flamelex state.

  The OmegaMaster holds all high-level global state, including:
    - the user-input mode
    - the input history (both keystrokes, & commands)
    - it acts as a conduit for all user-input (which got sent
      here by `Flamelex.GUI.RootScene`)

  We need a single junction-point where all the data required to make
  decisions can be combined & acted upon - this is it.

  What belongs in the domain of OmegaState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:
  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component
  * etc...
  changing the input mode alone requires that we make our changes at the
  OmegaMaster level, so we might as well just put the rest as side-effects
  in the reducer at this level. This makes sense because it's a heirarchy -
  since we need to change the input it's an OmegaMaster level change, so
  the function to open the Command buffer must be implemented at this level.
  If we don't need to alter anything at this level, then do not implement
  it in a reducer/handler at this level, handle it somewhere lower.

  When we need to trigger something at the Omega level, we can use actions.
  Actions get handled by a functiuon in the OmegaReducer module, though the
  actual processing occurs in a seperate process, running under the
  `Flamelex.Omega.HandleAction.TaskSupervisor`.

  User input also gets funneled through this process - the OmegaState (which
  includes the user-input history) and the input itself are handled by
  one of the InputHandler functions, which operate in basically the same
  manner as reducers - spun up into their own process & handled in there.
  Inputs usually lead to an action being dispatched, which is sent back
  to OmegaMaster (kind of a loop-back) to be then handled.
  """
  use GenServer
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.OmegaState


  def start_link(_params) do
    initial_state = OmegaState.new()
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc """
  This function enables us to fire actions off which enact changes, at
  the OmegaMaster level, but which aren't stricly responses to user input.

  If the process dispatching this action requires a callback, that's possible?
  """
  def action(a) do
    GenServer.cast(__MODULE__, {:action, a, []})
  end

  # def action(a, await_callback?: true) do
  #   GenServer.cast(__MODULE__, {:action, a, callback_pid: self()})
  #   receive do
  #     callback ->
  #       callback
  #   after
  #     @action_callback_timeout ->
  #       {:error, "timed out waiting for the action to callback"}
  #   end
  # end

  @doc """
  This function is called to channel all user input, e.g. keypresses,
  through the OmegaMaster, where they can be converted into actions.

  This function handles user input. All input from the entire GUI gets
  routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

  We use the OmegaState (which includes global variables such as which
  mode we are in, the input history [to allow chaining of keystrokes\] etc),
  as well as the input itself, to compute the new state.

  The effect of most user input will be either to ignore it, or to dispatch
  an action - this is achieved by sending a new msg to the OmegaMaster, which
  will in turn be handled by spinning up a new Task process to handle it.
  """
  def handle_user_input(ii) do
    GenServer.cast(__MODULE__, {:user_input, ii})
  end

  @doc """
  This exists because sometimes it's convenient to call it from IEx to get
  the value in OmegaMaster

  iex> OmegaMaster.debug
  """
  def debug, do: GenServer.cast(__MODULE__, :debug)


  # GenServer callbacks


  def init(%Flamelex.Structs.OmegaState{} = omega_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, omega_state}
  end

  def handle_cast({:user_input, input}, omega_state) do
    spawn_async_process(:handle_input, omega_state, input)
    {:noreply, omega_state |> OmegaState.record(keystroke: input)}
  end

  def handle_cast({:action, a, _list?}, omega_state) do
    IO.puts "GOT THE ACTION: #{inspect a}, init state: #{inspect omega_state}"
    case spawn_async_process(:handle_action, omega_state, a) do
      {:ok, %OmegaState{} = updated_omega_state} ->
        IO.puts "new omega state ; #{inspect omega_state}"
        {:noreply, updated_omega_state |> OmegaState.record(action: a)}
      {:error, reason} ->
        IO.puts "error proc action #{inspect a}, #{inspect reason}"
        {:noreply, omega_state}
    end
  end

  # def handle_cast(:debug, omega_state) do
  #   IO.puts "DEBUG: omega_state: #{inspect omega_state}"
  #   {:noreply, omega_state}
  # end

  @action_callback_timeout 500
  def spawn_async_process(:handle_action, omega_state, a) do

    Task.Supervisor.start_child(
      Flamelex.Omega.HandleAction.TaskSupervisor,
          Flamelex.Omega.Reducer,  # module
          :handle_action,          # function
          [omega_state, a])        # args

    # await the callback from processing the action
    receive do
      #NOTE: don't use a match here - if we get a msg back, let that msg
      #      tell us it it is an ok/error tuple or not
      callback ->
        IO.puts "#{__MODULE__} got the callback: #{inspect callback}, from action: #{inspect a}"
        callback
    after
      @action_callback_timeout ->
        {:error, "timed out waiting for the action to callback"}
    end
  end

  def spawn_async_process(:handle_input, omega_state, input) do

    #TODO key_mapping should be? a property of OmegaState
    #NOTE: key_mapping is an Elixir module implementing the KeyMapping behaviour #TODO
    key_mapping = Application.fetch_env!(:flamelex, :key_mapping)

    Flamelex.Omega.Input2ActionLookup.TaskSupervisor
    |> Task.Supervisor.start_child(
         __MODULE__,                          # module
         :lookup_action,                      # function
         [key_mapping, omega_state, input])   # args
  end

  #NOTE: `key_mapping` is  module, which (eventually) will be a `KeyMapping`
  #      behaviour - this infrastructure is in place, but until I get more
  #      than 1 key-mapping even made, I'm just gonna pattch match on the
  #      exact module name for safety
  @vim_clone_keymapping Flamelex.Utils.KeyMappings.VimClone
  def lookup_action(@vim_clone_keymapping = key_mapping, %OmegaState{} = omega_state, input) do
    IO.puts "#{__MODULE__} processing input... #{inspect input}"
    case key_mapping.lookup(omega_state, input) do
      :ignore_input ->
          :ok
      {:action, a} ->
          action(a) # dispatch the action by casting a msg back to OmegaMaster
      invalid_response ->
          IO.puts "\n\nthe input: #{inspect input} did not return a valid response: #{inspect invalid_response}"
          :error

      # {:apply_mfa, {module, function, args}} ->
      #     try do
      #       if res = Kernel.apply(module, function, args) == :err_not_handled do
      #         IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}"
      #       else
      #         res
      #         |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
      #       end
      #     rescue
      #       _e in UndefinedFunctionError ->
      #         Flamelex.Utilities.TerminalIO.red("Ignoring input #{inspect input}...\n\nMod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
      #         |> IO.puts()
      #       e ->
      #         raise e
      #     end
    end
  end
end
