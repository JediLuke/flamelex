defmodule Flamelex.Fluxus.NeoRootReducer do #TODO overtake old root reducer eventually
  @moduledoc """
  The RootReducer for all flamelex actions.

  Actions aren't handles in the caller process, instead a new Task is
  spun up to handle the processing - so any failures are contained to
  that task. The tasks are designed to call back if successful, so if
  they crash, either nothing will happen, or some timeouts will trigger
  if they were set further up the chain.
  """
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.Fluxus.Reducers

  @memex_actions [
    :open_memex
  ]

  def process(radix_state, action) when action in @memex_actions do
    Reducers.Memex.process(radix_state, action)
  end

  def process(radix_state, action) do
    {:error, "RootReducer bottomed-out! No match was found."}
  end

end
