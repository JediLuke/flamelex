defmodule Flamelex.Utils.PubSub do

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
