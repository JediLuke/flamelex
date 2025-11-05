defmodule Flamelex.GUI.Components.MenuBar.ScenicEventsDefinitions do
  @moduledoc """
  Contains module attribute definitions of all the Scenic input events.

  Example:

  ```
  defmodule SomeModule do
    use Flamelex.GUI.Components.MenuBar.ScenicEventsDefinitions

    ...

    handle_cast(@left_shift, state)
      ..

  ```

  Simply `use` this module to apply the macro that will bind all these
  constants, which match up to Scenic inputs, inside that module.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      # key-state numbers
      # These are the numbers used by Scenic to represent the
      # state of a key-press. I just prefer to use these names,
      # so I bind them here.
      # @key_pressed 0
      # @key_released 1

      # I think on mac & Linux these are reversed :(
      @key_pressed 1
      @key_released 0
      @key_held 2

      # for mouse-related events, e.g. `{:cursor_button, {:btn_left, 1, [], _coords}}`
      @click 1
      @clicked @click
      @release_click 0
      @un_click @release_click

      @space_bar {:key, {:key_space, @key_pressed, []}}

      @left_shift {:key, {:key_leftshift, @key_pressed, []}}
      @right_shift {:key, {:key_rightshift, @key_pressed, []}}
      @left_ctrl {:key, {:key_leftctrl, @key_pressed, []}}
      @right_ctrl {:key, {:key_rightctrl, @key_pressed, []}}
      @left_alt_dn {:key, {:key_leftalt, @key_pressed, []}}
      @left_alt_up {:key, {:key_leftalt, @key_released, [:alt]}}
      @left_cmd_dn {:key, {:key_leftsuper, @key_pressed, []}}
      @left_cmd_up {:key, {:key_leftsuper, @key_released, [:meta]}}
      @right_cmd_dn {:key, {:key_rightsuper, @key_pressed, []}}
      @right_cmd_up {:key, {:key_rightsuper, @key_released, [:meta]}}

      @tab_key {:key, {:key_tab, @key_pressed, []}}
      @enter_key {:key, {:key_enter, @key_pressed, []}}
      @backspace_key {:key, {:key_backspace, @key_pressed, []}}
      @delete_key {:key, {:key_delete, @key_pressed, []}}
      @escape_key {:key, {:key_esc, @key_pressed, []}}

      @open_bracket {:key, {:key_leftbracket, @key_pressed, []}}
      @close_bracket {:key, {:key_rightbracket, @key_pressed, []}}

      @arrow_up {:key, {:key_up, @key_pressed, []}}
      @arrow_down {:key, {:key_down, @key_pressed, []}}
      @arrow_left {:key, {:key_left, @key_pressed, []}}
      @arrow_right {:key, {:key_right, @key_pressed, []}}

      @key_0 {:key, {:key_0, @key_pressed, []}}
      @key_1 {:key, {:key_1, @key_pressed, []}}
      @key_2 {:key, {:key_2, @key_pressed, []}}
      @key_3 {:key, {:key_3, @key_pressed, []}}
      @key_4 {:key, {:key_4, @key_pressed, []}}
      @key_5 {:key, {:key_5, @key_pressed, []}}
      @key_6 {:key, {:key_6, @key_pressed, []}}
      @key_7 {:key, {:key_7, @key_pressed, []}}
      @key_8 {:key, {:key_8, @key_pressed, []}}
      @key_9 {:key, {:key_9, @key_pressed, []}}

      @alpha_a {:key, {:key_a, @key_pressed, []}}
      @alpha_b {:key, {:key_b, @key_pressed, []}}
      @alpha_c {:key, {:key_c, @key_pressed, []}}
      @alpha_d {:key, {:key_d, @key_pressed, []}}
      @alpha_e {:key, {:key_e, @key_pressed, []}}
      @alpha_f {:key, {:key_f, @key_pressed, []}}
      @alpha_g {:key, {:key_g, @key_pressed, []}}
      @alpha_h {:key, {:key_h, @key_pressed, []}}
      @alpha_i {:key, {:key_i, @key_pressed, []}}
      @alpha_j {:key, {:key_j, @key_pressed, []}}
      @alpha_k {:key, {:key_k, @key_pressed, []}}
      @alpha_l {:key, {:key_l, @key_pressed, []}}
      @alpha_m {:key, {:key_m, @key_pressed, []}}
      @alpha_n {:key, {:key_n, @key_pressed, []}}
      @alpha_o {:key, {:key_o, @key_pressed, []}}
      @alpha_p {:key, {:key_p, @key_pressed, []}}
      @alpha_q {:key, {:key_q, @key_pressed, []}}
      @alpha_r {:key, {:key_r, @key_pressed, []}}
      @alpha_s {:key, {:key_s, @key_pressed, []}}
      @alpha_t {:key, {:key_t, @key_pressed, []}}
      @alpha_u {:key, {:key_u, @key_pressed, []}}
      @alpha_v {:key, {:key_v, @key_pressed, []}}
      @alpha_w {:key, {:key_w, @key_pressed, []}}
      @alpha_x {:key, {:key_x, @key_pressed, []}}
      @alpha_y {:key, {:key_y, @key_pressed, []}}
      @alpha_z {:key, {:key_z, @key_pressed, []}}
    end
  end
end