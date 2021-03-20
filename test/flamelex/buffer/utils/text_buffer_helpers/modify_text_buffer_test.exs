defmodule Flamelex.Test.Buffer.Utils.TextBuffer.ModifyHelperTest do
  use ExUnit.Case
  alias Flamelex.Buffer.Utils.TextBuffer.ModifyHelper


    # sourced from: https://vim.fandom.com/wiki/Vim_buffer_FAQ
    @sentence_a "A buffer is a file loaded into memory for editing.\n"
    @sentence_b "All opened files are associated with a buffer.\n"
    @sentence_c "There are also buffers not associated with any file.\n"


  test "inserting text into a buffer, by specifying the overall character position to insert it" do
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

  # test "insert some text onto a line"

  describe "with standard test buffer" do
    setup [:standard_test_buffer]

    test "append a new line (insert under the current line)", %{buffer_state: buffer_state} do
      assert Enum.count(buffer_state.lines) == 3

      modification =  %{append: "\n", line: 1} # appent to line 1, means, we expect line 2 to be a blank new line
      {:ok, modified_buffer} = ModifyHelper.modify(buffer_state, modification)

      assert Enum.count(modified_buffer.lines) == 4
      assert modified_buffer.unsaved_changes? == true
      assert modified_buffer.data == @sentence_a <> "\n" <> @sentence_b <> @sentence_c
      assert modified_buffer.lines == [
        %{line: 1, text: @sentence_a |> String.trim()},
        %{line: 2, text: ""},
        %{line: 3, text: @sentence_b |> String.trim()},
        %{line: 4, text: @sentence_c |> String.trim()}
      ]
    end
  end


  test "insert some text into a buffer based on the cursor coordinates" do
    buffer_state = %{
      data: %{data: @sentence_a <> @sentence_b <> @sentence_c},
      lines: [ #NOTE: we trim there here, because, lines aren't supposed to contain newline chars
        %{line: 1, text: @sentence_a |> String.trim()},
        %{line: 2, text: @sentence_b |> String.trim()},
        %{line: 3, text: @sentence_c |> String.trim()},
      ],
      cursors: [
        # place the cursor a few words into the text
        %{col: String.length("All opened files"), line: 2} #TODO edge cases - what if the cursor is on the end of a line? the start of a line? the middle of a line? does the cursor position mean, on the cursor position, or after it?
      ],
      unsaved_changes?: false
    }
    modification = {:insert, " are freee!! And never,", %{coords: {:cursor, 1}}}

    {:ok, modified_buffer} = ModifyHelper.modify(buffer_state, modification)
    assert Enum.count(modified_buffer.lines) == 3 # NOTE: I never added any newline in my Modification
    assert modified_buffer.unsaved_changes? == true
    assert modified_buffer.lines == [
      %{line: 1, text: @sentence_a |> String.trim()},
      %{line: 2, text: "All opened files are freee!! And never, are associated with a buffer.\n" |> String.trim()},
      %{line: 3, text: @sentence_c |> String.trim()}
    ]
  end


  defp standard_test_buffer(context) do
    buffer_state = %{
      data: @sentence_a <> @sentence_b <> @sentence_c,
      lines: [ #NOTE: we trim there here, because, lines aren't supposed to contain newline chars
        %{line: 1, text: @sentence_a |> String.trim()},
        %{line: 2, text: @sentence_b |> String.trim()},
        %{line: 3, text: @sentence_c |> String.trim()},
      ],
      cursors: [%{line: 1, col: 1}],
      unsaved_changes?: false
    }

    context |> Map.merge(%{buffer_state: buffer_state})
  end
end
