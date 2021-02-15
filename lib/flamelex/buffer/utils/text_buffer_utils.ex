defmodule Flamelex.Buffer.Utils.TextBufferUtils do

  def parse_raw_text_into_lines(raw_text) do
    {lines_of_text, _final_accumulator} =
        raw_text
        |> String.split("\n") # split it up into each line based on newline char
        |> Enum.map_reduce(
                  1, # initialize accumulator to 1, so we start with line_num=1
                  fn line_of_text, line_num ->
                       {%{text: line_of_text, line: line_num}, line_num+1}
                  end)

    lines_of_text
  end
end
