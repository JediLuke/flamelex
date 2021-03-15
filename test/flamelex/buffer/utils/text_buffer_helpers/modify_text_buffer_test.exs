defmodule Flamelex.Test.Buffer.Utils.TextBuffer.ModifyHelperTest do
  use ExUnit.Case
  alias Flamelex.Buffer.Utils.TextBuffer.ModifyHelper


  # sourced from: https://vim.fandom.com/wiki/Vim_buffer_FAQ
  @sentence_a "A buffer is a file loaded into memory for editing.\n"
  @sentence_b "All opened files are associated with a buffer.\n"
  @sentence_c "There are also buffers not associated with any file.\n"


  test "inserting new text into a buffer - {:insert, \"text\", x}" do
    buffer_state = %{data: @sentence_a <> @sentence_b <> @sentence_c}
    modification = {:insert, "Luke is the best!", String.length(@sentence_a)}

    {:ok, modified_buffer} = ModifyHelper.modify(buffer_state, modification)

    assert modified_buffer.data == @sentence_a <> "Luke is the best!" <> @sentence_b <> @sentence_c
    assert Enum.count(modified_buffer.lines) == 3 # NOTE: I never added any newline in my Modification
    assert modified_buffer.unsaved_changes? == true
    assert modified_buffer.lines == [
      %{line: 1, text: @sentence_a |> String.trim()},
      %{line: 2, text: "Luke is the best!" <> @sentence_b |> String.trim()},
      %{line: 3, text: @sentence_c |> String.trim()}
    ]
  end

  test "insert some text onto a line"
  test "inserting newline chars into lines"
end
