defmodule Flamelex.GUI.Component.AgentHuddle.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the Agent huddle component.
  """
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.AgentHuddle
  alias Memelex.Lib.Structs.MemexConcepts.V01.Agent

  def process(%RadixState{} = rdx, :open_chat_window) do
    # case action do
    #   # Match on specific actions and call mutators
    #   _ ->
    #     rdx
    # end
    rdx
    |> AgentHuddle.Mutator.open_chat_window()
  end

  def process(%RadixState{} = rdx, :open_agent_settings) do
    # case action do
    #   # Match on specific actions and call mutators
    #   _ ->
    #     rdx
    # end
    rdx
    |> AgentHuddle.Mutator.open_agent_settings()
  end

  def process(%RadixState{} = rdx, :open_agent_five_loop) do
    # case action do
    #   # Match on specific actions and call mutators
    #   _ ->
    #     rdx
    # end
    rdx
    |> AgentHuddle.Mutator.open_agent_five_loop()
  end

  def process(%RadixState{} = rdx, {:activate_agent, %Memelex.TidBit{
    data: %Agent{status: :active}
  } = agent_t}) do
    Logger.error "Cant activate an agent which is already active!! #{agent_t.data.name}"
    rdx
  end

  def process(%RadixState{} = rdx, {:refresh_tidbit, %Memelex.TidBit{} = t}) do
    # Logger.error "Cant activate an agent which is already active!! #{agent_t.data.name}"
    rdx
    |> AgentHuddle.Mutator.refresh_tidbit(t)
  end


  def process(%RadixState{} = rdx, {:activate_agent, %Memelex.TidBit{
    data: %Agent{config: %{"mfa" => {agent_module, :start_link, [_args]}}}
  } = agent_t}) do
    r = Memelex.AgentHandler.boot_agent(agent_t.data)
    IO.inspect(r, label: "BOOT RESULT")

    rdx
    #case GenServer.call(agent_module, :activate) do
    # {:ok, new_agent_tidbit} ->
    #   rdx
    #   |> AgentHuddle.Mutator.refresh_tidbit(new_agent_tidbit)

    # {:error, reason} ->
    #   raise "Could not activate the agent, reason: #{inspect reason}"
    #end
  end

  def process(%RadixState{} = rdx, {:deactivate_agent, %Memelex.TidBit{
    data: %Agent{
      status: :active,
      config: %{"mfa" => {agent_module, :start_link, [_args]}}}
  }}) do
    # case Process.whereis(agent_module) do
    #   nil ->
    #     raise "Cannot deactivate agent #{inspect agent_module} - no process by that name can be found."

    #   p when is_pid(p) ->
    #     Process.exit(p, :kill)
    # end

    case GenServer.call(agent_module, :deactivate) do
      {:ok, new_agent_tidbit} ->
        rdx
        |> AgentHuddle.Mutator.refresh_tidbit(new_agent_tidbit)

      {:error, reason} ->
        raise "Could not deactivate the agent, reason: #{inspect reason}"
    end
  end

  def process(%RadixState{} = rdx, {:nudge_agent, %Memelex.TidBit{
    data: %Agent{
      config: %{"mfa" => {agent_module, :start_link, [_args]}}}
  }}) do
    # updates will get broadcast when the tidbit updates/saves so no need to update here
    GenServer.cast(agent_module, :nudge)

    rdx
    # case GenServer.call(agent_module, :nudge) do
    #   {:ok, new_agent_tidbit} ->
    #     rdx
    #     |> AgentHuddle.Mutator.refresh_tidbit(new_agent_tidbit)

    #   {:error, reason} ->
    #     raise "Could not deactivate the agent, reason: #{inspect reason}"
    # end
  end
end
