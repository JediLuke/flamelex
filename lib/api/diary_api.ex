#NOTE -

# The answer to this conundrum presented itself in time, as these things often do!

# I have now completely moved Memelex out to it's own application. It is embedded
# within Flamelex, but all control including the CLI now should live in that repo.

# Flamelex will still need the ability to dictate some high-level things e.g. the frame
# that the Memex/Diary will be drawn in, and we need to be able to funnel input down to
# Memelex through Flamelex (this is unavoidable because Flamelex needs to make the judgement
# call whether any input is Memelex input due to it holding the global state, `radix_state`,
# i.e. we may not even be on the Memelex screen)

# In the end, this module is going away.

# To open & close the Memex, we will need different controls
# ... to this end I just renamed the file diary_api.ex, because the
# memex view is going to end up being called the Diary view


defmodule Flamelex.API.Diary do
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
    # Logger.debug "#{__MODULE__} opening the Memex..."
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, :open_memex})
  end

  # def open(%Memelex.TidBit{uuid: uuid} = t) when is_bitstring(uuid) do
  #   Logger.debug "#{__MODULE__} opening the Memex with tidbit: `#{t.title}`..."
  #   # Flamelex.Fluxus.action({:open_tidbit, t})
  # end

  #TODO modify an existing TidBit (but that would require us to call)
  # def modify()

  def close do
    # Logger.debug "#{__MODULE__} closing the Memex..."
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, :close_memex})
  end

end