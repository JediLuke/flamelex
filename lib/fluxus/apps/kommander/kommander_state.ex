defmodule Flamelex.GUI.Component.Kommander.State do
  @moduledoc false
  # use StructAccess  # Temporarily commented due to compilation issues

  defstruct buf_ref: nil,
            font: nil

  def new do
    {:ok, buf_ref} = Quillex.Buffer.open(%{mode: {:kommander, :insert}})

    %__MODULE__{
      buf_ref: buf_ref,
      font: Flamelex.GUI.Component.QlxWrap.State.font()
    }
  end
end
