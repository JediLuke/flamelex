defmodule Structs.TidBit do
  @moduledoc false
  require Logger

  @derive Jason.Encoder
  defstruct [
    uuid: nil,
    hash: nil,
    title: nil,
    tags: [],
    creation_timestamp: nil,
    content: nil
  ]

  def initialize(%{title: title}) do
    %__MODULE__{
      uuid: "1",
      hash: "1",
      title: title,
      tags: ["first"],
      creation_timestamp: "Now",
      content: "Some hard-coded TidBit"
    }
  end
end
