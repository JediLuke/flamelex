defmodule Flamelex.API.Memex do
  @moduledoc """
  An API for the integrated Memex.

  #TODO maybe we can do something cool, like, route other functions from
  # Memex, to Memelex

  #NOTE I think the best answer may be to simply give the module name `Memex`
  #     to Flamelex, and rename the app that backs up the Memex to have
  #     module names starting with `Memelex` - avoiding the clash, keeping
  #     them seperate, making them both available while at the same time
  #     hopefully making a nice interface (thought I just realised they'll
  ##    collide :(  well we'll figure it out eventually
  """
  require Logger



  @doc ~s(Open the Memelex-GUI-pane inside Flamelex.)
  def open do
    Logger.debug "#{__MODULE__} opening the Memex..."
    Flamelex.Fluxus.action(:open_memex)
  end

  def open(%Memelex.TidBit{uuid: uuid} = t) when is_bitstring(uuid) do
    Logger.debug "#{__MODULE__} opening the Memex with tidbit: `#{t.title}`..."
    Flamelex.Fluxus.action({:open_tidbit, t})
  end

  def close do
    Logger.debug "#{__MODULE__} closing the Memex..."
    Flamelex.Fluxus.action(:close_memex)
  end


end