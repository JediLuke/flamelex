defmodule Flamelex.Utils.PubSub do
  @registrar_proc Flamelex.PubSub
  @topic :flamelex

  def subscribe, do: subscribe(topic: @topic)

  def subscribe(topic: t) do
    {:ok, _} = Registry.register(@registrar_proc, t, [])
    :ok
  end

  def broadcast(state_change: chng) do
    Registry.dispatch(@registrar_proc, @topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:state_change, chng})
    end)
  end

  def broadcast(topic: topic, msg: msg) do
    Registry.dispatch(@registrar_proc, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, msg)
    end)
  end
end
