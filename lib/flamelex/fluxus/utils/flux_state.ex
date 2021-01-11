defmodule Flamelex.Structs.OmegaState do
  @moduledoc false
  use Flamelex.ProjectAliases


  @max_keystroke_history_limit 50
  @max_action_history_limit 50


  defstruct [
    mode:                 :normal,    # The input mode
    keystroke_history:    [],         # A list of all previously entered user-input keystrokes
    action_history:       []          # A history of actions sent to OmegaMaster

    # active_buffer:  nil         # We need to know the active buffer
  ]

  def new do
    %__MODULE__{ mode: :normal }
  end

  @modes [:normal, :insert, :command]
  def set(%__MODULE__{} = omega, [mode: m]) when m in @modes do
    %{omega|mode: m}
  end

  def record(%__MODULE__{keystroke_history: keystroke_history} = omega, keystroke: k) do
    new_keystroke_history =
        keystroke_history
        |> add_to_list(k, max_length: @max_keystroke_history_limit)

    %{omega|keystroke_history: new_keystroke_history}
  end

  def record(%__MODULE__{action_history: action_history} = omega, action: a) do
    new_action_history =
        action_history
        |> add_to_list(a, max_length: @max_action_history_limit)

    %{omega|action_history: new_action_history}
  end

  # def last_keystroke_was?(%__MODULE__{keystroke_history: [last|_rest]}, x)
  #   when last == x do true end
  # def last_keystroke_was?(%__MODULE__{keystroke_history: _hist}, _x), do: false

  def add_to_list(list, x, max_length: max_list_length)
  when length(list) >= max_list_length
  do
    list_minus_one_item = # https://stackoverflow.com/questions/52319984/remove-last-element-from-list-in-elixir
      list
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()

    list_minus_one_item ++ [x]
  end

  def add_to_list(list, x, max_length: _max_list_length)
  when length(list) >= 0
  do
    list ++ [x]
  end

  def last_keystroke(%__MODULE__{keystroke_history: []}), do: nil
  def last_keystroke(%__MODULE__{keystroke_history: hist}) when length(hist) > 0 do
    hist
    |> Enum.reverse()
    |> hd()
  end
end
