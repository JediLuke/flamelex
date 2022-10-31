defmodule Flamelex.Utils.PubSub do
  @moduledoc """
  A wrapper of convenience around the internal PubSub functionality
  of flamelex.
  """

  def broadcast([topic: topic, msg: msg]) do
    :gproc.send({:p, :l, topic}, msg)
  end

  def subscribe([topic: topic]) do
    :gproc.reg({:p, :l, topic})
  end

  def unsubscribe([topic: _t]) do
    raise "now this one is a pickle isn't it"
  end
end
