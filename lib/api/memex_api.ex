defmodule Flamelex.API.MemexWrap do #TODO ah fuck I think I undid all this by accident - probably cause it was so stupid in the first place!
  @moduledoc """
  This is the Flamelex wrapper around Memelex - necessary for smooth
  integration with the UI.
  """
  require Logger

  @doc ~s(Open the Memelex pane inside Flamelex.)
  def open do
    Logger.debug "#{__MODULE__} opening the Memex..."
    Flamelex.Fluxus.Action.fire(:open_memex)
  end

  def close do
    Logger.debug "#{__MODULE__} closing the Memex..."
    Flamelex.Fluxus.Action.fire(:close_memex) # this is, really, at the end of the day - pushing all state through a syncronized point
  end

  #TODO maybe we can do something cool, like, route other functions from
  # Memex, to Memelex
end