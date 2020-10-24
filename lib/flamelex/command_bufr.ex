defmodule Flamelex.CommandBufr do
  @moduledoc """
  This module is really just an API of convenience for all this related
  to the CommandBufr.
  """

  def show do
    IO.puts "HWRE"
    Flamelex.OmegaMaster.show(:command_buffer)
  end

  def hide do
    Flamelex.OmegaMaster.hide(:command_buffer)
  end
end

# defmodule CommandBufr do

#   #TODO this is failing
#   #TODO publish to this, then both GUI.Controller must handle it & Buffer.Manager
#   # def show,                  do: how

#   def show do
#     GUIControl.
#   end


#   def hide,                  do: GenServer.cast(CmdBuffer, :hide)

#   def enter_character(char), do: GenServer.cast(CmdBuffer, {:enter_char, char})
#   def backspace,             do: GenServer.cast(CmdBuffer, :backspace)
#   def reset_text_field,      do: GenServer.cast(CmdBuffer, :reset_text_field)
#   def execute_contents,      do: GenServer.cast(CmdBuffer, :execute_contents)
# end
