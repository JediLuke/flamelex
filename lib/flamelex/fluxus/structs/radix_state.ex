defmodule Flamelex.Fluxus.Structs.RadixState do
  @moduledoc false
  use Flamelex.ProjectAliases


  @max_keystroke_history_limit 50
  @max_action_history_limit 50


  defstruct [
    mode:                 :normal,    # The input mode
    active_buffer:        nil,        # We need to know the active buffer - must be a %Flamelex.Structs.BufRef{}
    keystroke_history:    [],         # A list of all previously entered user-input keystrokes
    action_history:       [],         # A history of actions sent to FluxusRadix
    inbox_buffer:         [],         # when an action happens, we may need to buffer further actions until that one finishes - they are buffered here. we do same for keystrokes, so it's `inbox` buffer, to cover all cases
    runtime_config:       %{
      keymap:             Flamelex.API.KeyMappings.VimClone
    }
  ]

  @modes [:normal, :insert, {:command_buffer_active, :insert}]

  def new, do: default() #TODO deprecate

  def default do
    %__MODULE__{ mode: :normal }
  end

  #TODO ok, figure out how modes is gonna work, with active buffer etc...
  def set(%__MODULE__{} = radix_state, [mode: m]) when m in @modes do
    %{radix_state|mode: m}
  end

  def record(%__MODULE__{keystroke_history: keystroke_history} = radix_state, keystroke: k) do
    new_keystroke_history =
        keystroke_history
        |> add_to_list(k, max_length: @max_keystroke_history_limit)

    %{radix_state|keystroke_history: new_keystroke_history}
  end

  def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
    updated_history =
      action_history
      |> add_to_list(a, max_length: @max_action_history_limit)

    %{radix_state|action_history: updated_history}
  end

  def set_active_buffer(%__MODULE__{} = radix_state, b) do
    %{radix_state|active_buffer: b}
  end

  def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
    new_action_history =
        action_history
        |> add_to_list(a, max_length: @max_action_history_limit)

    %{radix_state|action_history: new_action_history}
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
