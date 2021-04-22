defmodule Flamelex.Memex.Structs.TidBit do
  @moduledoc """
  So, TidBit's are basically a complete rip-off tidlers.
  https://tiddlywiki.com/#TiddlerFields

  The only differences are, we add a changelog field #TODO and we use
  a UUID as the ultimate reference, not the title (though that is unique...)

  Also note we use the key `body` instead of `data`
  """

  @derive Jason.Encoder #TODO what does this do again?
  defstruct [
    uuid: nil,          # The UUID of the TidBit
    title: nil,         #	The unique name of a tiddler
    body: nil,          #	The body text/data of a tiddler
    modified: nil,      # The date and time at which a tiddler was last modified
    modifier: nil,      # The tiddler title associated with the person who last modified a tiddler
    created: nil,       # The date a tiddler was created
    creator: nil,       # The name of the person who created a tiddler
    tags: nil,          # A list of tags associated with a tiddler
    type:	nil,          # The content type of a tiddler
    list: nil,          # An ordered list of tiddler titles associated with a tiddler – see ListField
    caption: nil,       # The text to be displayed on a tab or button
    edit_log: nil       # A list of changes (with timestamps) so we can track changes to each TidBit
    #hash: nil           # we should hash the value of the entire tidler & store it here #TODO
  ]

  def cons(from_file: filepath) do
    # read the file, interpret as map, then construct new Struct
  end

  #   when is_binary(t) and is_list(tags) and is_binary(c) do
  #     data = data |> Map.merge(%{
  #       uuid: UUID.uuid4(),
  #       creation_timestamp: DateTime.utc_now()
  #     })

  #     # take a hash of all other elements in the map
  #     hash =
  #       :crypto.hash(:md5, data |> Jason.encode!())
  #       |> Base.encode16()
  #       |> String.downcase()
  #     data |> Map.merge(%{hash: hash}) #TODO test this hashing thing
  # end



    # def ack_reminder(reminder = %__MODULE__{tags: old_tags}) when is_list(old_tags) do
  #   new_tags =
  #     old_tags
  #     |> Enum.reject(& &1 == "reminder")
  #     |> Enum.concat(["ackd_reminder"])

  #   reminder |> Map.replace!(:tags, new_tags)
  # end
end
