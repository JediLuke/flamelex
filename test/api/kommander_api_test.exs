defmodule Test.Flamelex.API.Kommander do
  use ExUnit.Case


  # here's my rough script

  # - show the command buffer
  # - enter some text
  # - assert that the contents is equal to what we would expect
  # - execute that text, and asswert correct side effects happened
  # - assert that after execute, we have changed mode, and the Kommander isn't visible

  # - open kommander, use it to open a buffer
  # - assert buffer is open, kommander isn't visible
  # - open kommander, assert kommander is visible
  # - close the buffer, assert kommander isn't visible
  # - open the buffer, insert some text, assert the contents are correct
  # - clear the buffer, then assert the contents are empty again, the cursor has reset, but the buffer is still visible

  # - test out deactivate, which does clear and hides

  # - test backspace when inputting text




#TODO vim test - test the keybinding <space>k, calls Kommander.open()



end
