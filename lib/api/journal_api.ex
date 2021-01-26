defmodule Flamelex.API.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases


  def today do
    Flamelex.Fluxus.fire_action(:open_todays_journal_entry)
  end
end
