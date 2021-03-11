defmodule Flamelex.Buffer.Utils.TextBufferUtils do #TODO rename module to MiscUtils
  use Flamelex.ProjectAliases


  def save(%{source: {:file, filepath}} = state) do

    {:ok, file} = File.open(filepath, [:write])
    IO.binwrite(file, state.data) #TODO - maybe?
    :ok = File.close(file)

    {:ok, state |> Map.put(:unsaved_changes?, false)}
  end

  def parse_raw_text_into_lines(raw_text) do
    {lines_of_text, _final_accumulator} =
        raw_text
        |> String.split("\n") # split it up into each line based on newline char
        |> if_last_line_is_empty_string_remove_it()
        |> Enum.map_reduce(
                  1, # initialize accumulator to 1, so we start with line_num=1
                  fn line_of_text, line_num ->
                       {%{text: line_of_text, line: line_num}, line_num+1}
                  end)

    lines_of_text
  end

  def if_last_line_is_empty_string_remove_it(sliced_text) when is_list(sliced_text) do
    # when a string finishes with a "\n" character, using `String.split/1`
    # puts an empty string at the end of the list - which kind of makes
    # sense, since `split/1` is concerned with dicing up the string into
    # things which are either side of that character/substring. In our case
    # though, we don't want to make a whole new line, just for that empty
    # string...
    if List.last(sliced_text) == "" do
      List.delete_at(sliced_text, -1) # remove the last element
    else
      sliced_text
    end
  end

  # the opposite of parse_raw_text_into_lines/1
  def join_lines_into_raw_text(lines) do
    Enum.reduce(lines, "", fn %{text: t}, acc -> acc <> t end)
  end

end
