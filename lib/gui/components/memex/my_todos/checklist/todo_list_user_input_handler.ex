defmodule Flamelex.GUI.Component.TODOlist.UserInputHandler do
  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.{TODOlist, TODOdetails}

  @ignored_keys [
    @left_alt_dn,
    @left_alt_up
  ]
  def handle(rdx, input) when input in @ignored_keys do
    Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
    :ignore
  end

  def handle(rdx, @left_shift) do
    [{TODOlist, {:set_turbo, true}}]
  end

  def handle(rdx, @left_shift_up) do
    [{TODOlist, {:set_turbo, false}}]
  end

  def handle(rdx, @escape_key) do
    [{TODOdetails.Reducer, :close_todo_details}]
  end

  # Catch-all clause for any unhandled input
  def handle(_rdx, input) do
    Logger.debug("#{__MODULE__} received unhandled input: #{inspect(input)}")
    :ignore
  end
end
