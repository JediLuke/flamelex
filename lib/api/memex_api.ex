defmodule Flamelex.API.Memex do
  @moduledoc """
  This is the Flamelex wrapper around Memelex - necessary for smooth
  integration with the UI.
  """
  require Logger

  @doc ~s(Open the Memelex pane inside Flamelex.)
  def open do
    Logger.debug "#{__MODULE__} opening the Memex..."
    Flamelex.Fluxus.action(:open_memex)
  end

  def open(%Memelex.TidBit{uuid: uuid} = t) when is_bitstring(uuid) do
    Logger.debug "#{__MODULE__} opening the Memex..."
    Flamelex.Fluxus.action({:open_tidbit, t})
  end

  def close do
    Logger.debug "#{__MODULE__} closing the Memex..."
    Flamelex.Fluxus.action(:close_memex) # this is, really, at the end of the day - pushing all state through a syncronized point
  end

  def tiggle_search do
    Logger.debug "#{__MODULE__} closing the Memex..."
    Flamelex.Fluxus.action(:tiggle_search)
  end

  #TODO maybe we can do something cool, like, route other functions from
  # Memex, to Memelex

  #NOTE I think the best answer may be to simply give the module name `Memex`
  #     to Flamelex, and rename the app that backs up the Memex to have
  #     module names starting with `Memelex` - avoiding the clash, keeping
  #     them seperate, making them both available while at the same time
  #     hopefully making a nice interface (thought I just realised they'll
  ##    collide :(  well we'll figure it out eventually
end