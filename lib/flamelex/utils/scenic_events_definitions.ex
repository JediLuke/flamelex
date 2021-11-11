defmodule Flamelex.GUI.ScenicEventsDefinitions do
  @moduledoc """
  Contains module attribute definitions of all the Scenic input events.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do

      @inputs_we_dont_care_about [
        :viewport_enter,
        :viewport_exit,
        :cursor_pos,
        :cursor_enter,
        :cursor_exit
      ]

      # key-state numbers
      # -----------------
      # These are the numbers used by Scenic to represent the
      # state of a key-press. I just prefer to use these names,
      # so I bind them here.
      @key_pressed 0
      @key_released 1
      @key_held 2

      # for mouse-related events, e.g. `{:cursor_button, {:btn_left, 1, [], _coords}}`
      @click 1
      @release_click 0
      
      @left_shift_press {:key, {:key_leftshift, @key_pressed, []}}
      @escape_key {:key, {:key_esc, @key_pressed, []}}
      @enter_key {:key, {:key_enter, @key_pressed, []}}
      @backspace_key {:key, {:key_backspace, @key_pressed, []}}
      # @backspace_repeat {:key, {"backspace", :repeat, 0}}
      # @backspace_input [@backspace_key, @backspace_repeat]
      @tab_key {:key, {:key_tab, @key_pressed, []}}

      @space_bar {:key, {:key_space, @key_pressed, []}}

      @left_shift_and_space_bar {:key, {:key_space, @key_pressed, [:shift]}} # {:key, {" ", :press, 1}}
      @left_shift_and_tab {:key, {:key_tab, @key_pressed, [:shift]}} # {:key, {"tab", :press, 1}}

      #NOTE: even though these are numbers, the last one in the tuple
      #      we send, is still always zero
      @number_0 {:key, {:key_0, @key_pressed, []}}
      @number_1 {:key, {:key_1, @key_pressed, []}}
      @number_2 {:key, {:key_2, @key_pressed, []}}
      @number_3 {:key, {:key_3, @key_pressed, []}}
      @number_4 {:key, {:key_4, @key_pressed, []}}
      @number_5 {:key, {:key_5, @key_pressed, []}}
      @number_6 {:key, {:key_6, @key_pressed, []}}
      @number_7 {:key, {:key_7, @key_pressed, []}}
      @number_8 {:key, {:key_8, @key_pressed, []}}
      @number_9 {:key, {:key_9, @key_pressed, []}}

      @lowercase_a {:key, {:key_a, @key_pressed, []}}
      @lowercase_b {:key, {:key_b, @key_pressed, []}}
      @lowercase_c {:key, {:key_c, @key_pressed, []}}
      @lowercase_d {:key, {:key_d, @key_pressed, []}}
      @lowercase_e {:key, {:key_e, @key_pressed, []}}
      @lowercase_f {:key, {:key_f, @key_pressed, []}}
      @lowercase_g {:key, {:key_g, @key_pressed, []}}
      @lowercase_h {:key, {:key_h, @key_pressed, []}}
      @lowercase_i {:key, {:key_i, @key_pressed, []}}
      @lowercase_j {:key, {:key_j, @key_pressed, []}}
      @lowercase_k {:key, {:key_k, @key_pressed, []}}
      @lowercase_l {:key, {:key_l, @key_pressed, []}}
      @lowercase_m {:key, {:key_m, @key_pressed, []}}
      @lowercase_n {:key, {:key_n, @key_pressed, []}}
      @lowercase_o {:key, {:key_o, @key_pressed, []}}
      @lowercase_p {:key, {:key_p, @key_pressed, []}}
      @lowercase_q {:key, {:key_q, @key_pressed, []}}
      @lowercase_r {:key, {:key_r, @key_pressed, []}}
      @lowercase_s {:key, {:key_s, @key_pressed, []}}
      @lowercase_t {:key, {:key_t, @key_pressed, []}}
      @lowercase_u {:key, {:key_u, @key_pressed, []}}
      @lowercase_v {:key, {:key_v, @key_pressed, []}}
      @lowercase_w {:key, {:key_w, @key_pressed, []}}
      @lowercase_x {:key, {:key_x, @key_pressed, []}}
      @lowercase_y {:key, {:key_y, @key_pressed, []}}
      @lowercase_z {:key, {:key_z, @key_pressed, []}}

      @uppercase_A {:key, {:key_a, @key_pressed, [:shift]}}
      @uppercase_B {:key, {:key_b, @key_pressed, [:shift]}}
      @uppercase_C {:key, {:key_c, @key_pressed, [:shift]}}
      @uppercase_D {:key, {:key_d, @key_pressed, [:shift]}}
      @uppercase_E {:key, {:key_e, @key_pressed, [:shift]}}
      @uppercase_F {:key, {:key_f, @key_pressed, [:shift]}}
      @uppercase_G {:key, {:key_g, @key_pressed, [:shift]}}
      @uppercase_H {:key, {:key_h, @key_pressed, [:shift]}}
      @uppercase_I {:key, {:key_i, @key_pressed, [:shift]}}
      @uppercase_J {:key, {:key_j, @key_pressed, [:shift]}}
      @uppercase_K {:key, {:key_k, @key_pressed, [:shift]}}
      @uppercase_L {:key, {:key_l, @key_pressed, [:shift]}}
      @uppercase_M {:key, {:key_m, @key_pressed, [:shift]}}
      @uppercase_N {:key, {:key_n, @key_pressed, [:shift]}}
      @uppercase_O {:key, {:key_o, @key_pressed, [:shift]}}
      @uppercase_P {:key, {:key_p, @key_pressed, [:shift]}}
      @uppercase_Q {:key, {:key_q, @key_pressed, [:shift]}}
      @uppercase_R {:key, {:key_r, @key_pressed, [:shift]}}
      @uppercase_S {:key, {:key_s, @key_pressed, [:shift]}}
      @uppercase_T {:key, {:key_t, @key_pressed, [:shift]}}
      @uppercase_U {:key, {:key_u, @key_pressed, [:shift]}}
      @uppercase_V {:key, {:key_v, @key_pressed, [:shift]}}
      @uppercase_W {:key, {:key_w, @key_pressed, [:shift]}}
      @uppercase_X {:key, {:key_x, @key_pressed, [:shift]}}
      @uppercase_Y {:key, {:key_y, @key_pressed, [:shift]}}
      @uppercase_Z {:key, {:key_z, @key_pressed, [:shift]}}

      @lowercase_letters [
        @lowercase_a, @lowercase_b, @lowercase_c, @lowercase_d, @lowercase_e,
        @lowercase_f, @lowercase_g, @lowercase_h, @lowercase_i, @lowercase_j,
        @lowercase_k, @lowercase_l, @lowercase_m, @lowercase_n, @lowercase_o,
        @lowercase_p, @lowercase_q, @lowercase_r, @lowercase_s, @lowercase_t,
        @lowercase_u, @lowercase_v, @lowercase_w, @lowercase_x, @lowercase_y,
        @lowercase_z
      ]

      @uppercase_letters [
        @uppercase_A, @uppercase_B, @uppercase_C, @uppercase_D, @uppercase_E,
        @uppercase_F, @uppercase_G, @uppercase_H, @uppercase_I, @uppercase_J,
        @uppercase_K, @uppercase_L, @uppercase_M, @uppercase_N, @uppercase_O,
        @uppercase_P, @uppercase_Q, @uppercase_R, @uppercase_S, @uppercase_T,
        @uppercase_U, @uppercase_V, @uppercase_W, @uppercase_X, @uppercase_Y,
        @uppercase_Z
      ]

      @all_letters @lowercase_letters ++ @uppercase_letters

      @period {:key, {:key_dot, @key_pressed, []}}
      @bang {:key, {:key_1, @key_pressed, [:shift]}}
      @question_mark {:key, {:key_slash, @key_pressed, [:shift]}}
      @colon {:key, {:key_semicolon, @key_pressed, [:shift]}}
      @comma {:key, {:key_comma, @key_pressed, []}}
      @quote_character {:key, {:key_apostrophe, @key_pressed, [:shift]}}
      @underscore {:key, {:key_minus, @key_pressed, [:shift]}}
      @percent_sign {:key, {:key_5, @key_pressed, [:shift]}}
      @left_parenthesis {:key, {:key_9, @key_pressed, [:shift]}}
      @right_parenthesis {:key, {:key_0, @key_pressed, [:shift]}}
      @left_brace {:key, {:key_leftbrace, @key_pressed, [:shift]}}
      @right_brace {:key, {:key_rightbrace, @key_pressed, [:shift]}}

      @all_punctuation [@period, @bang, @question_mark, @colon, @comma,
        @quote_character, @percent_sign, @left_parenthesis, @right_parenthesis,
        @left_brace, @right_brace]

      @valid_text_input_characters @all_letters ++ @all_punctuation ++ [@space_bar]

      ## convert a keystroke into a string - used for inputing text

      def key2string(@number_0), do: "0"
      def key2string(@number_1), do: "1"
      def key2string(@number_2), do: "2"
      def key2string(@number_3), do: "3"
      def key2string(@number_4), do: "4"
      def key2string(@number_5), do: "5"
      def key2string(@number_6), do: "6"
      def key2string(@number_7), do: "7"
      def key2string(@number_8), do: "8"
      def key2string(@number_9), do: "9"

      def key2string(@escape), do: "escape"
      def key2string(@space_bar), do: " "

      def key2string(@lowercase_a), do: "a"
      def key2string(@lowercase_b), do: "b"
      def key2string(@lowercase_c), do: "c"
      def key2string(@lowercase_d), do: "d"
      def key2string(@lowercase_e), do: "e"
      def key2string(@lowercase_f), do: "f"
      def key2string(@lowercase_g), do: "g"
      def key2string(@lowercase_h), do: "h"
      def key2string(@lowercase_i), do: "i"
      def key2string(@lowercase_j), do: "j"
      def key2string(@lowercase_k), do: "k"
      def key2string(@lowercase_l), do: "l"
      def key2string(@lowercase_m), do: "m"
      def key2string(@lowercase_n), do: "n"
      def key2string(@lowercase_o), do: "o"
      def key2string(@lowercase_p), do: "p"
      def key2string(@lowercase_q), do: "q"
      def key2string(@lowercase_r), do: "r"
      def key2string(@lowercase_s), do: "s"
      def key2string(@lowercase_t), do: "t"
      def key2string(@lowercase_u), do: "u"
      def key2string(@lowercase_v), do: "v"
      def key2string(@lowercase_w), do: "w"
      def key2string(@lowercase_x), do: "x"
      def key2string(@lowercase_y), do: "y"
      def key2string(@lowercase_z), do: "z"

      def key2string(@uppercase_A), do: "A"
      def key2string(@uppercase_B), do: "B"
      def key2string(@uppercase_C), do: "C"
      def key2string(@uppercase_D), do: "D"
      def key2string(@uppercase_E), do: "E"
      def key2string(@uppercase_F), do: "F"
      def key2string(@uppercase_G), do: "G"
      def key2string(@uppercase_H), do: "H"
      def key2string(@uppercase_I), do: "I"
      def key2string(@uppercase_J), do: "J"
      def key2string(@uppercase_K), do: "K"
      def key2string(@uppercase_L), do: "L"
      def key2string(@uppercase_M), do: "M"
      def key2string(@uppercase_N), do: "N"
      def key2string(@uppercase_O), do: "O"
      def key2string(@uppercase_P), do: "P"
      def key2string(@uppercase_Q), do: "Q"
      def key2string(@uppercase_R), do: "R"
      def key2string(@uppercase_S), do: "S"
      def key2string(@uppercase_T), do: "T"
      def key2string(@uppercase_U), do: "U"
      def key2string(@uppercase_V), do: "V"
      def key2string(@uppercase_W), do: "W"
      def key2string(@uppercase_X), do: "X"
      def key2string(@uppercase_Y), do: "Y"
      def key2string(@uppercase_Z), do: "Z"

      def key2string(@period), do: "."
      def key2string(@bang), do: "!"
      def key2string(@question_mark), do: "?"

      def key2string(@underscore), do: "_"

      def key2string(@left_parenthesis), do: "("
      def key2string(@right_parenthesis), do: ")"


      def key2string(x) do
        #NOTE: I originally had this here for debugging, but it raises
        #      an interesting question - maybe it's just one's personal
        #      style, but, should we put this catchall here? I guess that
        #      question becomes, do we want things to start crashing if
        #      we can't convert a key to it's known string.
        #
        #      On the one hand, obviously we are not able to process the
        #      original intent of the request - we have no direct way of
        #      mapping this key to it's actually intended string representation -
        #      and since we can't service the request, we should fail. 
        #      Probably, an erlang purist would revert to the classic
        #      'let it crash!' maxim - but to me it's an engineering/design
        #      choice.
        #
        #      On the other hand, maybe that's not enough of a reason to
        #      fail! After all, we could just map it to something stupid
        #      like "X" or "?" or whatever (interestingly there's no
        #      character glyff for "null" on a standard modern keyboard !?)
        #
        #      I think the most fundamental truth about what I have learned
        #      from working with the BEAM is that it's important to understand
        #      and know how your program *will* fail, so you can design
        #      around that - which is the actual source of robust programs,
        #      - good design.
        raise "Unable to convert #{inspect x} to a valid string."
      end

    end
  end
end
