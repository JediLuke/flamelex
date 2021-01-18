defmodule Flamelex.Fluxus.Actions.Basic do

  def switch_mode(m)  when is_atom(m) do
    {:action, {:active_buffer, :switch_mode, m}}
  end

  def move_cursor([to: destination]) do
    {:action, {:active_buffer, :move_cursor, %{to: destination}}}
  end
  def move_cursor(direction, amount, unit) do
    {:action, {:active_buffer, :move_cursor, %{direction: direction, amount: amount, unit: unit}}}
    # {:apply_mfa, {Flamelex.Buffer.Text, :move_cursor, [:active_buffer, {direction,  amount}]}} #TODO no MFA, fire an action
  end
end
