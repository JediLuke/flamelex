defmodule Flamelex.API.Memex do
  @moduledoc """
  This is the Flamelex wrapper around Memelex - necessary for smooth
  integration with the UI.
  """
  require Logger

  @doc ~s(Open the Memelex pane inside Flamelex.)
  def open do
    Logger.debug "#{__MODULE__} opening the Memex..."
    raise "not implemented"
  end
end