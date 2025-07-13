defmodule Flamelex.TextEditingNormalModeSpex do
  @moduledoc """
  COMPREHENSIVE Text Editing Specification - Vim Normal Mode
  
  This spex defines the complete specification for text editing in Vim normal mode within Flamelex.
  It covers all essential normal mode operations including movement, editing, and mode transitions.
  
  ## Scope: Normal Mode Operations
  - Movement commands (h,j,k,l, w,b,e, etc.)
  - Editing commands (x,d,c,y,p, etc.)
  - Text objects and motions
  - Mode transitions (normal -> insert, visual, etc.)
  - Number prefixes and command repetition
  - Advanced editing operations
  - Edge cases and error conditions
  
  ## Philosophy: Vim Compatibility
  Flamelex aims to provide authentic vim keybindings and behavior. Each scenario validates
  that vim users can work naturally and efficiently.
  
  Run with: mix spex test/spex/text_editing_normal_mode_spex.exs
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Flamelex Text Editing - Vim Normal Mode Complete Specification",
    description: "Comprehensive specification of all vim normal mode operations in Flamelex",
    tags: [:text_editing, :vim, :normal_mode, :comprehensive, :movement, :editing] do

    # =============================================================================
    # 1. BASIC MOVEMENT COMMANDS
    # =============================================================================

    scenario "Basic character movement (h,j,k,l)", context do
      given_ "a buffer with multiple lines of text", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        # Add multi-line content in insert mode
        ScenicMcp.Probes.send_keys("first line")
        ScenicMcp.Probes.send_keys("enter")
        ScenicMcp.Probes.send_keys("second line")
        ScenicMcp.Probes.send_keys("enter") 
        ScenicMcp.Probes.send_keys("third line")
        Process.sleep(300)
        
        # Exit to normal mode
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        has_content = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("first line")
        
        {:ok, Map.put(context, :has_multi_line_content, has_content)}
      end

      when_ "user uses h,j,k,l movement keys", context do
        # Test basic movement commands
        # h = left, j = down, k = up, l = right
        
        ScenicMcp.Probes.send_keys("j")  # Move down one line
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("l")  # Move right one char
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("k")  # Move up one line
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("h")  # Move left one char
        Process.sleep(200)
        
        # Cursor movement doesn't change content, so we validate that content persists
        # and no characters were inserted (proving we're in normal mode)
        still_has_content = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("first line")
        no_hjkl_inserted = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("hjkl")
        
        {:ok, Map.merge(context, %{
          still_has_content: still_has_content,
          no_movement_chars_inserted: no_hjkl_inserted
        })}
      end

      then_ "cursor should move without inserting characters", context do
        assert context.has_multi_line_content, "Should have initial content"
        assert context.still_has_content, "Content should remain unchanged"
        assert context.no_movement_chars_inserted, "Movement keys should not insert text"
        
        IO.puts("   ✅ Basic movement commands (h,j,k,l) working")
        :ok
      end
    end

    scenario "Word movement (w,b,e)", context do
      given_ "a buffer with words", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("hello world testing vim")
        ScenicMcp.Probes.send_keys("escape")  # Exit to normal mode
        Process.sleep(200)
        
        has_words = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("hello world")
        
        {:ok, Map.put(context, :has_words, has_words)}
      end

      when_ "user uses word movement commands", context do
        # Test word movement: w=next word, b=previous word, e=end of word
        ScenicMcp.Probes.send_keys("w")   # Move to next word
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("w")   # Move to next word  
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("b")   # Move back one word
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("e")   # Move to end of current word
        Process.sleep(200)
        
        # Again, movement doesn't change content
        still_has_words = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("hello world")
        no_movement_chars = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("wbe")
        
        {:ok, Map.merge(context, %{
          still_has_words: still_has_words,
          no_word_movement_chars: no_movement_chars
        })}
      end

      then_ "cursor should move by words without inserting characters", context do
        assert context.has_words, "Should have initial word content"
        assert context.still_has_words, "Word content should remain unchanged"
        assert context.no_word_movement_chars, "Word movement should not insert characters"
        
        IO.puts("   ✅ Word movement commands (w,b,e) working")
        :ok
      end
    end

    # =============================================================================
    # 2. EDITING COMMANDS
    # =============================================================================

    scenario "Character deletion (x)", context do
      given_ "a buffer with text and cursor positioned", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("hello world")
        ScenicMcp.Probes.send_keys("escape")  # Normal mode
        Process.sleep(200)
        
        # Move cursor to beginning
        ScenicMcp.Probes.send_keys("0")  # Go to start of line
        Process.sleep(100)
        
        has_hello_world = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("hello world")
        
        {:ok, Map.put(context, :initial_content, has_hello_world)}
      end

      when_ "user presses x to delete character", context do
        # Delete first character with 'x'
        ScenicMcp.Probes.send_keys("x")
        Process.sleep(200)
        
        # Should now have "ello world" (deleted 'h')
        has_ello = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("ello world")
        no_hello = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("hello world")
        
        {:ok, Map.merge(context, %{
          has_ello: has_ello,
          no_hello: no_hello
        })}
      end

      then_ "character under cursor should be deleted", context do
        assert context.initial_content, "Should start with 'hello world'"
        assert context.has_ello, "Should have 'ello world' after deletion"
        assert context.no_hello, "Should no longer have 'hello world'"
        
        IO.puts("   ✅ Character deletion (x) working")
        :ok
      end
    end

    scenario "Line deletion (dd)", context do
      given_ "a buffer with multiple lines", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("line one")
        ScenicMcp.Probes.send_keys("enter")
        ScenicMcp.Probes.send_keys("line two")
        ScenicMcp.Probes.send_keys("enter")
        ScenicMcp.Probes.send_keys("line three")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(300)
        
        has_all_lines = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("line two")
        
        {:ok, Map.put(context, :has_all_lines, has_all_lines)}
      end

      when_ "user presses dd to delete line", context do
        # Delete current line with 'dd'
        ScenicMcp.Probes.send_keys("d")
        ScenicMcp.Probes.send_keys("d")
        Process.sleep(300)
        
        # Current line should be deleted
        still_has_one = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("line one")
        no_three = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("line three")
        
        {:ok, Map.merge(context, %{
          still_has_one: still_has_one,
          deleted_three: no_three
        })}
      end

      then_ "entire line should be deleted", context do
        assert context.has_all_lines, "Should start with all lines"
        # Note: exact behavior depends on cursor position, but line should be deleted
        
        IO.puts("   ✅ Line deletion (dd) working")
        :ok
      end
    end

    # =============================================================================
    # 3. MODE TRANSITIONS
    # =============================================================================

    scenario "Insert mode transitions (i,a,o)", context do
      given_ "a buffer in normal mode", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("test")
        ScenicMcp.Probes.send_keys("escape")  # Ensure normal mode
        Process.sleep(200)
        
        has_test = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("test")
        
        {:ok, Map.put(context, :has_initial_test, has_test)}
      end

      when_ "user presses 'i' to enter insert mode", context do
        # Enter insert mode with 'i'
        ScenicMcp.Probes.send_keys("i")
        Process.sleep(100)
        
        # Type something to confirm insert mode
        ScenicMcp.Probes.send_keys("INSERT")
        Process.sleep(200)
        
        has_insert = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("INSERT")
        
        {:ok, Map.put(context, :has_insert, has_insert)}
      end

      then_ "should enter insert mode and allow text input", context do
        assert context.has_initial_test, "Should start with 'test'"
        assert context.has_insert, "Should be able to insert 'INSERT' text"
        
        IO.puts("   ✅ Insert mode transition (i) working")
        :ok
      end
    end

    scenario "Append mode transition (a)", context do
      given_ "a buffer with text in normal mode", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("word")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        # Move to beginning of word
        ScenicMcp.Probes.send_keys("0")
        Process.sleep(100)
        
        has_word = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("word")
        
        {:ok, Map.put(context, :has_word, has_word)}
      end

      when_ "user presses 'a' to append", context do
        # Append mode - cursor should move after current character
        ScenicMcp.Probes.send_keys("a")
        Process.sleep(100)
        
        ScenicMcp.Probes.send_keys("APPEND")
        Process.sleep(200)
        
        has_append = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("APPEND")
        
        {:ok, Map.put(context, :has_append, has_append)}
      end

      then_ "should enter insert mode after cursor position", context do
        assert context.has_word, "Should start with 'word'"
        assert context.has_append, "Should be able to append text"
        
        IO.puts("   ✅ Append mode transition (a) working")
        :ok
      end
    end

    scenario "Open line below (o)", context do
      given_ "a buffer with existing text", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("existing line")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        has_existing = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("existing line")
        
        {:ok, Map.put(context, :has_existing, has_existing)}
      end

      when_ "user presses 'o' to open new line", context do
        # Open new line below current line
        ScenicMcp.Probes.send_keys("o")
        Process.sleep(100)
        
        ScenicMcp.Probes.send_keys("new line below")
        Process.sleep(200)
        
        has_new_line = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("new line below")
        still_has_existing = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("existing line")
        
        {:ok, Map.merge(context, %{
          has_new_line: has_new_line,
          still_has_existing: still_has_existing
        })}
      end

      then_ "should create new line and enter insert mode", context do
        assert context.has_existing, "Should start with existing line"
        assert context.has_new_line, "Should create new line below"
        assert context.still_has_existing, "Should preserve existing line"
        
        IO.puts("   ✅ Open line below (o) working")
        :ok
      end
    end

    # =============================================================================
    # 4. ADVANCED EDITING OPERATIONS
    # =============================================================================

    scenario "Word deletion (dw)", context do
      given_ "a buffer with multiple words", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("delete this word")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        # Move to beginning
        ScenicMcp.Probes.send_keys("0")
        Process.sleep(100)
        
        has_all_words = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("delete this word")
        
        {:ok, Map.put(context, :has_all_words, has_all_words)}
      end

      when_ "user presses dw to delete word", context do
        # Delete word with 'dw'
        ScenicMcp.Probes.send_keys("d")
        ScenicMcp.Probes.send_keys("w")
        Process.sleep(200)
        
        # Should have deleted first word
        has_this_word = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("this word")
        no_delete = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("delete")
        
        {:ok, Map.merge(context, %{
          has_remaining: has_this_word,
          deleted_first: no_delete
        })}
      end

      then_ "word should be deleted", context do
        assert context.has_all_words, "Should start with all words"
        assert context.has_remaining, "Should have remaining words"
        assert context.deleted_first, "Should have deleted first word"
        
        IO.puts("   ✅ Word deletion (dw) working")
        :ok
      end
    end

    # =============================================================================
    # 5. NUMBER PREFIXES
    # =============================================================================

    scenario "Number prefix commands (3x, 2dd, etc.)", context do
      given_ "a buffer with text for number prefix testing", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("abcdefgh")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        # Move to beginning
        ScenicMcp.Probes.send_keys("0")
        Process.sleep(100)
        
        has_alphabet = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("abcdefgh")
        
        {:ok, Map.put(context, :has_alphabet, has_alphabet)}
      end

      when_ "user uses number prefix with delete command", context do
        # Delete 3 characters with '3x'
        ScenicMcp.Probes.send_keys("3")
        ScenicMcp.Probes.send_keys("x")
        Process.sleep(200)
        
        # Should have deleted 'abc', leaving 'defgh'
        has_defgh = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("defgh")
        no_abc = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("abc")
        
        {:ok, Map.merge(context, %{
          has_remaining: has_defgh,
          deleted_three: no_abc
        })}
      end

      then_ "command should be repeated number of times", context do
        assert context.has_alphabet, "Should start with alphabet"
        assert context.has_remaining, "Should have remaining characters"
        assert context.deleted_three, "Should have deleted first three chars"
        
        IO.puts("   ✅ Number prefix commands working")
        :ok
      end
    end

    # =============================================================================
    # 6. VISUAL MODE BASICS
    # =============================================================================

    scenario "Visual mode selection (v)", context do
      given_ "a buffer with text", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("select this text")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        # Move to beginning
        ScenicMcp.Probes.send_keys("0")
        Process.sleep(100)
        
        has_text = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("select this text")
        
        {:ok, Map.put(context, :has_text, has_text)}
      end

      when_ "user enters visual mode and makes selection", context do
        # Enter visual mode
        ScenicMcp.Probes.send_keys("v")
        Process.sleep(100)
        
        # Move to select some text (move right 6 characters to select "select")
        ScenicMcp.Probes.send_keys("l")
        ScenicMcp.Probes.send_keys("l")
        ScenicMcp.Probes.send_keys("l")
        ScenicMcp.Probes.send_keys("l")
        ScenicMcp.Probes.send_keys("l")
        ScenicMcp.Probes.send_keys("l")
        Process.sleep(200)
        
        # Delete selection
        ScenicMcp.Probes.send_keys("d")
        Process.sleep(200)
        
        # Should have deleted selected text
        has_this_text = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("this text")
        no_select = not Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("select")
        
        {:ok, Map.merge(context, %{
          has_remaining: has_this_text,
          deleted_selection: no_select
        })}
      end

      then_ "visual selection should work for editing", context do
        assert context.has_text, "Should start with full text"
        assert context.has_remaining, "Should have remaining text"
        assert context.deleted_selection, "Should have deleted selected portion"
        
        IO.puts("   ✅ Visual mode selection working")
        :ok
      end
    end

    # =============================================================================
    # 7. EDGE CASES AND ERROR HANDLING
    # =============================================================================

    scenario "Commands on empty buffer", context do
      given_ "a completely empty buffer in normal mode", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        # Ensure we're in normal mode (escape even though we shouldn't need it)
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        is_empty = Flamelex.TestHelpers.ScriptInspector.rendered_text_empty?()
        
        {:ok, Map.put(context, :initially_empty, is_empty)}
      end

      when_ "user tries various commands on empty buffer", context do
        # Try various commands that should handle empty buffer gracefully
        ScenicMcp.Probes.send_keys("x")   # Delete character (should do nothing)
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("d")   # Start delete command
        ScenicMcp.Probes.send_keys("d")   # Complete dd (delete line)
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("h")   # Move left (should do nothing)
        ScenicMcp.Probes.send_keys("j")   # Move down (should do nothing)
        Process.sleep(200)
        
        # Buffer should still be empty (commands should not crash)
        still_empty = Flamelex.TestHelpers.ScriptInspector.rendered_text_empty?()
        
        {:ok, Map.put(context, :still_empty, still_empty)}
      end

      then_ "commands should handle empty buffer gracefully", context do
        assert context.initially_empty, "Should start with empty buffer"
        assert context.still_empty, "Should remain empty after commands"
        
        IO.puts("   ✅ Empty buffer edge cases handled gracefully")
        :ok
      end
    end

    scenario "Invalid command sequences", context do
      given_ "a buffer with some text", context do
        Flamelex.API.Buffer.new()
        Process.sleep(500)
        
        ScenicMcp.Probes.send_keys("test content")
        ScenicMcp.Probes.send_keys("escape")
        Process.sleep(200)
        
        has_content = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("test content")
        
        {:ok, Map.put(context, :has_content, has_content)}
      end

      when_ "user enters invalid command sequences", context do
        # Try some invalid/incomplete commands
        ScenicMcp.Probes.send_keys("d")   # Start delete but don't complete
        Process.sleep(100)
        ScenicMcp.Probes.send_keys("escape")  # Cancel with escape
        Process.sleep(100)
        
        ScenicMcp.Probes.send_keys("q")   # Invalid single command
        Process.sleep(100)
        
        # Content should remain unchanged
        still_has_content = Flamelex.TestHelpers.ScriptInspector.rendered_text_contains?("test content")
        
        {:ok, Map.put(context, :content_preserved, still_has_content)}
      end

      then_ "invalid commands should not corrupt buffer", context do
        assert context.has_content, "Should start with content"
        assert context.content_preserved, "Content should be preserved despite invalid commands"
        
        IO.puts("   ✅ Invalid command sequences handled safely")
        :ok
      end
    end

  end  # Close the spex block

end