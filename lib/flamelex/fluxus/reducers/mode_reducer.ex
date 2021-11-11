defmodule Flamelex.Fluxus.Reducers.Mode do
  @moduledoc """
  Helper functions, called by the `RootReducer`, to process actions related
  to `modes`
  """
  use Flamelex.ProjectAliases
  require Logger

  def handle(%{mode: current_mode} = radix_state, {:action, {:switch_mode, m}}) do
    Logger.debug "#{__MODULE__} switching from `#{inspect current_mode}` to `#{inspect m}` mode..."
    radix_state |> switch_mode(m)
  end


  #NOTE: I debated internally somewhat to the idea of
  #      making this a private function...
  #
  #      On the one hand, this is the key logic that achieves everything!
  #      All the side-effects happen right here! On the other hand, all
  #      the side-effects happen right here...
  #
  #      The argument against private functions, mainly seems to me to be
  #      that, one day somebody will need to "reach under the hood" and
  #      go around the intentions of the designer, to fix a problem, or
  #      understand something better, or whatever.
  #
  #      The argument for making this a private function would be, under
  #      normal circumstances we absolutely do not want a user to call
  #      this function!! Why?? Because if we call this directly, we haven't
  #      gone through the proper messaging channels - several (important!!)
  #      processes, will not have been updated correctly, e.g.
  #      `Flamelex.Fluxus`, which holds the root stater. This will surely
  #      cause additional problems/confusion, likely leading to needing
  #      some kind of restart, or lots of debugging.
  #
  #      Perhaps it truly is a case-by-case basis. In this case, I am making
  #      it a private function, because:
  #        a) I don't want to get into the habit of calling it during dev,
  #           when it would be such bad practice once it's working
  #        b) If Flamelex does ever get popular, I don't want to handle
  #           ten thousand support requests where people break their runtime.
  #           Flamelex is open-source, you compile it locally, if you ever
  #           really need to get under the hood, well - you found it. I
  #           hope you know what you are doing!! Good Luck.
  defp switch_mode(radix_state, m) do
    new_radix_state = %{radix_state|mode: m} # update the state with the new mode

    Flamelex.Utils.PubSub.broadcast([
      topic: :gui_update_bus,
      msg: {:switch_mode, m}])

    GenServer.cast(Flamelex.FluxusRadix, {:radix_state_update, new_radix_state})

    :ok
  end
end
