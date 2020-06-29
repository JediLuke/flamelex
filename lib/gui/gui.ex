defmodule GUI do

  def new_buffer([text: t]) do
    Franklin.action({'NEW_LIST_BUFFER', data})
  end
end
