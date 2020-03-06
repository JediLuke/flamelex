defmodule Franklin.Test.Note do
  use ExUnit.Case

  describe "creating a new note" do
    test "is done by entering `note` into command buffer"
  end

  describe "when you create a new note" do
    test "a blank note buffer appears on screen"
    test "a blinking cursor appears at the start of the title"
    test "the blank note buffer that appears has a placeholder prompt for a title"
    test "the blank note buffer that appears has some placeholder text"
    test "you are put into edit (insert) mode", do: flunk "Not yet implemented."
  end

  describe "when editing a notes title" do
    test "you are in edit/insert mode"
    test "you are able to enter text"
    test "text entered gets appended to the title"
    test "you can backspace text", do: flunk
    test "you can not backspace past the beginning of the title", do: flunk
    test "if you backspace to the beginning, you will see the original title prompt string again", do: flunk
    test "you can press TAB to move the cursor into the text area"
    test "when you tab to the text, if there is already real text in the note (e.g. you previously entered text and tabbed out), the cursor is placed at the end of the text"
    test "press escape to go back to command mode"
  end

  describe "when editing a notes text" do
    test "you are in edit/insert mode"
    test "you are able to enter text"
    test "text entered gets appended to the note"
    test "you can backspace text", do: flunk
    test "you can not backspace past the beginning of the title", do: flunk
    test "if you backspace to the beginning, you will see the original title prompt string again", do: flunk
    test "you can press TAB to move the cursor into the text area"
    test "you can press left shift + TAB to go back to editing the title"
    test "when you shift-tab back to the title, the cursor is placed at the end of the title"
    test "press escape to go back to command mode"
  end

  describe "when in control mode and a notes buffer is active" do
    test "press enter to save it & close the buffer"
    test "escape discards the note", do: flunk
  end

  describe "when saving a note" do
    test "the `note` tag is added"
    test "any other tags are added"
    test "it gets saved with the UUID as the key"
    test "it saves the title"
    test "it saves the text"
    test "it saves the datetime (and timezone) that the note was saved"
  end
end
