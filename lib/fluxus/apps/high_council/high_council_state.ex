defmodule Flamelex.GUI.Component.HighCouncil.State do
  @moduledoc """
  State management for the High council component.
  """
  # use StructAccess  # Temporarily commented due to compilation issues
  alias Memelex.Lib.Structs.MemexConcepts.V01.Agent

  defstruct agents: [],
            new_agent_mode?: false

  def new(query_memex?: true) do
    # somewhere, we have to just call the damn Memex,
    # might as well encapculate it behind the function
    # where I want to make a new one
    agents = Memelex.My.Agents.all()

    %__MODULE__{agents: agents}
  end

  def new(query_memex?: false) do
    # in this case, we dont want to query the memex
    # because it's bootup (probably, maybe not) and I don't
    # want to have a bull-rush on components trying to
    # query the memex to get state all at once, when those
    # components aren't even being asked to load yet
    # agents = Memelex.My.Agents.all()
    %__MODULE__{}
  end
end
