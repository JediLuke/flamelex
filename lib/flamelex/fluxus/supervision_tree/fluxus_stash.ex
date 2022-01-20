defmodule Flamelex.Fluxus.Stash do
  @moduledoc """
  This module just stores the actual state itself - modifications are
  made elsewhere.

  https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/
  """
  use Agent


  @fluxus_radix %{
    mode:           :normal,
    buffers: %{
      # active:       {:file, todays_journal_filepath()},
      active:       nil,
      open:         [
        # %Buffer{
        #             # rego_tag:
        #             type: Flamelex.Buffer.Text,
        #             source: {:file, filepath},
        #             label: filepath,
        #             mode: :normal,
        #             # open_in_gui?: true, #TODO set active buffer
        #             # callback_list: [self()]
        #             data: file_contents,    # the raw data
        #             unsaved_changes?: nil,  # a flag to say if we have unsaved changes
        #             # time_opened #TODO
        #             cursors: [%{line: 1, col: 1}],
        #             lines: file_contents |> TextBufferUtils.parse_raw_text_into_lines(),
        #             # gui_data: %{
        #             #   component_rego: ,

        #             # }
        # }
      ]
    },
    history: %{
      keystrokes:   [],
      actions:      []
    },
    config: %{
      keymap:       Flamelex.API.KeyMappings.VimClone
    }
  }


  def start_link(_params) do
    Agent.start_link(fn -> @fluxus_radix end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  def update(new_value) do
    Agent.update(__MODULE__, fn _state -> new_value end)
  end
end
