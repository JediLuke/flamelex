defmodule Flamelex.Test.API.CommandBufferTest do
  use ExUnit.Case

end


# defmodule Franklin.Test.CommandBuffer do
#   use ExUnit.Case

#   test "able to activate the command buffer"
#   test "able to deactivate the command buffer"


#   describe "when in control mode" do
#     test "press `space` to bring up the command buffer (if it's hidden)"
#     test "press `space` to enter a space character in the command buffer (if the command buffer is visible)"
#     test "press `escape` to close & clear the command buffer (if it's visible)"
#     test "press `left_shift + space` to close & clear the command buffer (if it's visible)"
#     test "press `backspace` to backspace text in the command buffer (if the command buffer is visible)"
#   end

#   describe "visually, the command buffer" do
#     test "shows a prompt"
#     test "has a blinking cursor"
#     test "shows text when you enter it"
#     test "deletes text when you backspace it"
#     test "cursor moves 1 character along each time you enter a new character"
#     test "cursor moves back 1 character each time you backspace a new character"
#     test "cursor cant backspace past where we started from"
#     test "shows a text prompt when there's no text entered"
#     test "shows a text prompt when you hav entered text, but backspaced it till there is none again"
#     test "shows a status message if a command fails", do: flunk "not yet implemented."
#   end

#   describe "command buffer command" do
#     test "gets processed by the `Commander` module"
#     test "does nothing if it does not recognise a command"
#   end

#   describe "the command" do
#     test "`note` - creates a new note"
#     test "`restart` - restarts Franklin"
#     test "`help` - opens help", do: flunk "not yet implemented."
#     test "`reload GUI` - reloads the GUI"
#   end
# end
