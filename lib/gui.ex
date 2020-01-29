defmodule GUI do
  @moduledoc """
  This module is responsible for providing all the Franklin GUI interface
  functions.
  """

  defdelegate startup_process_childspec_list, to: GUI.Initialize
end
