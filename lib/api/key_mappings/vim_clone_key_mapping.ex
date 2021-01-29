defmodule Flamelex.API.KeyMappings.VimClone do
  @moduledoc """
  Implements the Vim keybindings for editing text inside flamelex.

  https://hea-www.harvard.edu/~fine/Tech/vi.html
  """
  use Flamelex.Fluxux.KeyMappingBehaviour
  alias Flamelex.Structs.BufRef

  @doc ~s(Define the leader key here.)
  def leader, do: @space_bar


  @doc ~s(This function maps defines the act of pressing a key, to an action.)
  def keymap(%RadixState{mode: :normal, active_buffer: %BufRef{type: Flamelex.Buffer.Text} = active_buf}) do
    %{
      # enter_insert_mode_after_current_character
      # @lowercase_a => [:active_buffer |> CoreActions.move_cursor(:forward, 1, :character),
      #                  :active_buffer |> switch_mode(:insert)],
      # @lowercase_b => TextBufferActions.move_cursor(:back, 1, :word),
      # @lowercase_c => vim_language_command(:change),
      # @lowercase_d => vim_language_command(:delete),
      # @lowercase_e => vim_language(:end) #:active_buffer |> CoreActions.move_cursor(:end, :word), #TODO this is tough... we want to be able to go dte, etc...
      # @lowercase_f => find_character(:current_line, :after_cursor, {:direction, :forward}) #TODO vim language command??
      # @lowercase_g => #unbound
      @lowercase_h => {:fire_action, {:move_cursor, %{buffer: active_buf, details: %{cursor_num: 1, instructions: {:left, 1, :column}}}}},
      # @lowercase_i => CoreActions.switch_mode(:insert),
      @lowercase_j => {:fire_action, {:move_cursor, %{buffer: active_buf, details: %{cursor_num: 1, instructions: {:down, 1, :line}}}}},
      @lowercase_k => {:fire_action, {:move_cursor, %{buffer: active_buf, details: %{cursor_num: 1, instructions: {:up, 1, :line}}}}},
      @lowercase_l => {:fire_action, {:move_cursor, %{buffer: active_buf, details: %{cursor_num: 1, instructions: {:right, 1, :column}}}}},
      # @lowercase_l => CoreActions.move_cursor(:right, 1, :column),
      # @lowercase_m => place_mark(:current_position)
      # @lowercase_n => repeat_last_search
      # @lowercase_o => open_line_below_and_go_into_insert_mode
      #TODO next!!???
      # @lowercase_p => paste(:default_paste_bin, :after, :cursor) # vim calls this `put`
      # @lowercase_q => #unbound
      # @lowercase_r => replace_single_character_at_cursor()
      # @lowercase_s => substitute_single_character_with_new_text()
      # @lowercase_t => CoreActions.move_cursor_till_just_before_find_character()
      #TODO also important!!!j
      # @lowercase_u => undo()
      # @lowercase_v => #unbound
      # @lowercase_w => CoreActions.move_cursor(:forward, 1, :word),
      # @lowercase_x => delete_character(at: :cursor)
      # @lowercase_y => yank()
      # @lowercase_z => position_current_line()

      # @uppercase_A => enter_insertion_mode_after_line()
      # @uppercase_B => CoreActions.move_cursor(:back, 1, :word),
      # @uppercase_C => change(to: :end_of_line)
      # @uppercase_D => delete(to: :end_of_line)
      # @uppercase_E => CoreActions.move_cursor(to: :end_of_current_word),
      # @uppercase_F => find_character(:current_line, :after_cursor, {:direction, :reverse})
      # @uppercase_G => :active_buffer |> move_cursor(to: :last_line), #TODO implement proper vim handling, how to get it to accept pre-G alpha numeric... how to explain this... either use a pre-cursor, or go to end (just go to end by defualt???)
      # @uppercase_G => {:action, {:active_buffer, :CoreActions.move_cursor, {:last_line, :same_column}}}, #TODO when actibve buf is text?? How do we handle this???
      # @uppercase_H => goto_line(1) # home cursor
      # @uppercase_I => CoreActions.move_cursor(to: :first_non_whitespace_character, :current_line, :backwards), switch_mode(:insert)
      #TODO also important!!
      # @uppercase_J => join_line_below()
      # @uppercase_K => #unbound
      # @uppercase_L => CoreActions.move_cursor(:last_line_visible_on_screen)
      # @uppercase_M => CoreActions.move_cursor(:middle_line_visible_on_screen)
      # @uppercase_N => repeat_last_dearch(firection: :backward)
      # @uppercase_O => open_line(:above), :enterINsert_mode
      # @uppercase_P => paste(:default_padst_bin, :before, :cursor)
      # @uppercase_Q => switch_mode(:ex)
      # @uppercase_R => switch_mode(:replace)
      # @uppercase_S => delete_line, enter_insert_mode
      # @uppercase_T => CoreActions.move_cursor_till_just_before_find_character(direction: :backward)
      # @uppercase_U => restore_line_to_state_before_cursor_moved_in_to_it()
      # @uppercase_V => #unbound
      # @uppercase_W => CoreActions.move_cursor(:forward, 1, :word)
      # @uppercase_X => delete_character(1, :column, :before, :cursor)
      # @uppercase_Y => yank(:current_line)
      # @uppercase_Z => first_hald_quick_save_and_exit??

      # @number_0 => CoreActions.move_cursor(column_number: 0)
      # @number_1 => CoreActions.move_cursor(column_number: 0)
      # @number_2 => CoreActions.move_cursor(column_number: 0)
      # @number_3 => CoreActions.move_cursor(column_number: 0)
      # @number_4 => CoreActions.move_cursor(column_number: 0)
      # @number_5 => CoreActions.move_cursor(column_number: 0)
      # @number_6 => CoreActions.move_cursor(column_number: 0)
      # @number_7 => CoreActions.move_cursor(column_number: 0)
      # @number_8 => CoreActions.move_cursor(column_number: 0)
      # @number_9 => CoreActions.move_cursor(column_number: 0)


      # !	shell command filter	cursor motion command, shell command
      # @	vi eval	buffer name (a-z)
      # #	UNBOUND
      # $	move to end of line
      # %	match nearest [],(),{} on line, to its match (same line or others)
      # ^	move to first non-whitespace character of line
      # &	repeat last ex substitution (":s ...") not including modifiers
      # *	UNBOUND
      # (	move to previous sentence
      # )	move to next sentence
      # \	UNBOUND
      # |	move to column zero
      # -	move to first non-whitespace of previous line
      # _	similar to "^" but uses numeric prefix oddly
      # =	UNBOUND
      # +	move to first non-whitespace of next line
      # [	move to previous "{...}" section	"["
      # ]	move to next "{...}" section	"]"
      # {	move to previous blank-line separated section	"{"
      # }	move to next blank-line separated section	"}"
      # ;	repeat last "f", "F", "t", or "T" command
      # '	move to marked line, first non-whitespace	character tag (a-z)
      # `	move to marked line, memorized column	character tag (a-z)
      # :	ex-submode	ex command
      # "	access numbered buffer; load or access lettered buffer	1-9,a-z
      # ~	reverse case of current character and move cursor forward
      # ,	reverse direction of last "f", "F", "t", or "T" command
      # .	repeat last text-changing command
      # /	search forward	search string, ESC or CR
      # <	unindent command	cursor motion command
      # >	indent command	cursor motion command
      # ?	search backward	search string, ESC or CR
      # ^A	UNBOUND
      # ^B	back (up) one screen
      # ^C	UNBOUND
      # ^D	down half screen
      # ^E	scroll text up (cursor doesn't move unless it has to)
      # ^F	foreward (down) one screen
      # ^G	show status
      # ^H	backspace
      # ^I	(TAB) UNBOUND
      # ^J	line down
      # ^K	UNBOUND
      # ^L	refresh screen
      # ^M	(CR) move to first non-whitespace of next line
      # ^N	move down one line
      # ^O	UNBOUND
      # ^P	move up one line
      # ^Q	XON
      # ^R	does nothing (variants: redraw; multiple-redo)
      # ^S	XOFF
      # ^T	go to the file/code you were editing before the last tag jump
      # ^U	up half screen
      # ^V	UNBOUND
      # ^W	UNBOUND
      # ^X	UNBOUND
      # ^Y	scroll text down (cursor doesn't move unless it has to)
      # ^Z	suspend program
      # ^[	(ESC) cancel started command; otherwise UNBOUND
      # ^\	leave visual mode (go into "ex" mode)
      # ^]	use word at cursor to lookup function in tags file, edit that file/code
      # ^^	switch file buffers
      # ^_	UNBOUND
      # ^?	(DELETE) UNBOUND

    }
  end

  # def lookup(%RadixState{mode: :insert} = radix_state, input) when input in @valid_text_input_characters do
  #   #TODO how do we know its cursor 1?
  #   {:apply_mfa, {
  #                   Flamelex.API.Buffer,
  #                   :modify,
  #                   [:active_buffer, {:insert, input, {:cursor, 1}}]
  #                 }
  #   } #TODO generalize this to non-text buffers too
  # end
  def keymap(%RadixState{mode: :normal, active_buffer: %BufRef{type: Flamelex.Buffer.Text} = active_buf}) do
    %{
      @escape_key => CoreActions.switch_mode(:normal)
    }
  end


  @doc ~s(This function allows users to define custom leader key-bindings.)
  def leader_keybindings(%RadixState{mode: :normal}) do
    %{
      @lowercase_j => {:apply_mfa, {Flamelex.API.Journal, :today, []}},
      @lowercase_k => {:apply_mfa, {Flamelex.API.CommandBuffer, :show, []}},
      @lowercase_t => {:apply_mfa, {Flamelex.API.Memex.TiddlyWiki, :open, []}}, #TODO

      @lowercase_x => {:execute_function, fn -> raise "intentionally raising! little x" end},
      @uppercase_X => {:execute_function, fn -> raise "intentionally raising! big X" end}
    }
  end
end
