defmodule Flamelex.API.GUI.ScenicEventsDefinitions do
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

      @left_shift_press {:key, {"left_shift", :press, 1}}
      @escape_key {:key, {"escape", :press, 0}}
      @enter_key {:key, {"enter", :press, 0}}
      @backspace_key {:key, {"backspace", :press, 0}}
      @backspace_repeat {:key, {"backspace", :repeat, 0}}
      @backspace_input [@backspace_key, @backspace_repeat]
      @tab_key {:key, {"tab", :press, 0}}

      @space_bar {:codepoint, {" ", 0}}

      @left_shift_and_space_bar {:key, {" ", :press, 1}}
      @left_shift_and_tab {:key, {"tab", :press, 1}}

      @lowercase_a {:codepoint, {"a", 0}}
      @lowercase_b {:codepoint, {"b", 0}}
      @lowercase_c {:codepoint, {"c", 0}}
      @lowercase_d {:codepoint, {"d", 0}}
      @lowercase_e {:codepoint, {"e", 0}}
      @lowercase_f {:codepoint, {"f", 0}}
      @lowercase_g {:codepoint, {"g", 0}}
      @lowercase_h {:codepoint, {"h", 0}}
      @lowercase_i {:codepoint, {"i", 0}}
      @lowercase_j {:codepoint, {"j", 0}}
      @lowercase_k {:codepoint, {"k", 0}}
      @lowercase_l {:codepoint, {"l", 0}}
      @lowercase_m {:codepoint, {"m", 0}}
      @lowercase_n {:codepoint, {"n", 0}}
      @lowercase_o {:codepoint, {"o", 0}}
      @lowercase_p {:codepoint, {"p", 0}}
      @lowercase_q {:codepoint, {"q", 0}}
      @lowercase_r {:codepoint, {"r", 0}}
      @lowercase_s {:codepoint, {"s", 0}}
      @lowercase_t {:codepoint, {"t", 0}}
      @lowercase_u {:codepoint, {"u", 0}}
      @lowercase_v {:codepoint, {"v", 0}}
      @lowercase_w {:codepoint, {"w", 0}}
      @lowercase_x {:codepoint, {"x", 0}}
      @lowercase_y {:codepoint, {"y", 0}}
      @lowercase_z {:codepoint, {"z", 0}}

      @uppercase_A {:codepoint, {"A", 1}}
      @uppercase_B {:codepoint, {"B", 1}}
      @uppercase_C {:codepoint, {"C", 1}}
      @uppercase_D {:codepoint, {"D", 1}}
      @uppercase_E {:codepoint, {"E", 1}}
      @uppercase_F {:codepoint, {"F", 1}}
      @uppercase_G {:codepoint, {"G", 1}}
      @uppercase_H {:codepoint, {"H", 1}}
      @uppercase_I {:codepoint, {"I", 1}}
      @uppercase_J {:codepoint, {"J", 1}}
      @uppercase_K {:codepoint, {"K", 1}}
      @uppercase_L {:codepoint, {"L", 1}}
      @uppercase_M {:codepoint, {"M", 1}}
      @uppercase_N {:codepoint, {"N", 1}}
      @uppercase_O {:codepoint, {"O", 1}}
      @uppercase_P {:codepoint, {"P", 1}}
      @uppercase_Q {:codepoint, {"Q", 1}}
      @uppercase_R {:codepoint, {"R", 1}}
      @uppercase_S {:codepoint, {"S", 1}}
      @uppercase_T {:codepoint, {"T", 1}}
      @uppercase_U {:codepoint, {"U", 1}}
      @uppercase_V {:codepoint, {"V", 1}}
      @uppercase_W {:codepoint, {"W", 1}}
      @uppercase_X {:codepoint, {"X", 1}}
      @uppercase_Y {:codepoint, {"Y", 1}}
      @uppercase_Z {:codepoint, {"Z", 1}}

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

      @period {:codepoint, {".", 0}}
      @bang {:codepoint, {"!", 1}}
      @question_mark {:codepoint, {"?", 1}}
      @left_bracket {:codepoint, {"(", 1}}
      @right_bracket {:codepoint, {")", 1}}
      @quote_character {:codepoint, {"\"", 1}}
      @colon {:codepoint, {":", 1}}
      @percent_sign {:codepoint, {"%", 1}}
      @left_brace {:codepoint, {"{", 1}}
      @right_brace {:codepoint, {"}", 1}}
      @comma {:codepoint, {",", 0}}

      @valid_command_buffer_inputs @all_letters ++ [@space_bar, @period,
        @bang, @question_mark, @left_bracket, @right_bracket, @quote_character,
        @colon, @percent_sign, @left_brace, @right_brace, @comma]

    end
  end
end
