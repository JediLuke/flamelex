defmodule Flamelex.GUI.Component.TODOlist.State do
  use StructAccess
  alias Flamelex.Fluxus.RadixState

  defstruct list: [],
            selected: nil,
            scroll: {0, 0},
            turbo_scroll?: false,
            filter: nil,
            sort_order: :default,  # :default, :priority_high, :priority_low, :date_newest, :date_oldest
            creating_new_todo?: false,
            new_todo_form: %{title: "", description: "", priority: :medium}

  def new do
    %__MODULE__{}
  end
end
