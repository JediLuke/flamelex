defmodule Flamelex.GUI.Structs.LineOfText do
  @moduledoc """
  Struct which holds a line of text - just like this one.
  """
  use Flamelex.{ProjectAliases, CustomGuards}

  @default_column_limit 72


  defstruct [
    text:                 "",
    line_num:             nil,    # in this case, indices start at 1. This is to represent files as ordered lines of text, e.g. this is line12 of this file
    max_num_characters:   nil     # the maximum width a line of text can be, measured in number of characters/columns
  ]


  def new(%{
    text: line_of_text, line_num: line_num
  }) when is_bitstring(line_of_text) and is_integer(line_num) do

    max_num_characters  = @default_column_limit
    truncated_line      = line_of_text |> String.slice(0, max_num_characters)

    %__MODULE__{
      text: truncated_line,
      line_num: line_num,
      max_num_characters: max_num_characters
    }
  end
end
