defmodule Flamelex.Structs.Buf do
  @moduledoc """
  Points to a Buffer in Flamelex - but it isn't the buffer itself! Just a
  reference to one.
  """
  use Flamelex.{ProjectAliases, CustomGuards}


  @valid_buffer_types [:text]


  defstruct [
    ref:        nil,  # a unique reference, used to register the buffer process, eg. {:file, "some/filepath"} or "lukesBuffer"
    number:     nil,  # if we want to give buffers numbers, ie. to order them
    type:       nil,  # tells us if its a text buffer or whatever
    label:       nil,  # a short name for the buffer, doesn't have to be unique
    title:      nil,  # an optional title, for displaying in window bars etc
    tags:       [],   # a list of tags... this is for the future

  ]


  def new(%{type: t, ref: r} = params) when t in @valid_buffer_types do
    if is_valid_ref?(r) do
        %__MODULE__{
          type: t,
          ref: r,
          label: params.label
        }
    else
      raise invalid_ref_param_error_string()
    end
  end

  def invalid_ref_param_error_string do
    "the `ref` param provided to #{__MODULE__}.new/1 is missing or invalid"
  end

  def invalid_ref_param_error_string(params) do
    "the `ref` param provided to #{__MODULE__}.new/1 is missing or invalid\n\nparams: #{inspect params}\n"
  end

  @doc """
  This is the tag used to register buffer processes. You can also pass it
  a map, & it will either return the rego_tag matching the params, or `:error`
  """
  def rego_tag(%__MODULE__{ref: ref}), do: rego_tag(ref)
  def rego_tag(%{ref: ref}), do: rego_tag(ref)
  def rego_tag(%{file: path}) when is_bitstring(path), do: rego_tag({:file, path})
  def rego_tag({:file, path} = tag) when is_bitstring(path) do
    {:buffer, tag}
  end
  def rego_tag(_else), do: :error

  def is_valid_ref?({:file, path}) when is_bitstring(path), do: true
  def is_valid_ref?(s) when is_bitstring(s), do: true
  def is_valid_ref?(_ref), do: false

end

# Utilities.ProcessRegistry.fetch_buffer_pid!(file_name)
# |> Franklin.Flamelex.Buffer.Text.insert("WooLoo", [after: 3])

# def update_content(%__MODULE__{} = buf, with: c) do
#   %{buf|content: c}
# end

# # take a hash of all other elements in the map
# hash =
# :crypto.hash(:md5, data |> Jason.encode!())
# |> Base.encode16()
# |> String.downcase()
#      data |> Map.merge(%{hash: hash}) #TODO test this hashing thing
#    end





      # # all buffers have the same basic function, so they can all define
      # # the same struct, and then simply have different fields for data
      # defstruct [
      #   name:     nil,  # a *unique* identifier. This will be used to
      #                   # register processes across various functions e.g.
      #                   # {:buffer, name} and {:gui_component, name}.
      #                   # could be a tuple itself, e.g. {"Count of Monte Cristo", :page, 78}
      #   label:     nil,  # a short, non-unique (?), simple string used for
      #                   # conveniently accessing buffers, e.g. "countMC78"
      #                   # or "buffer1"
      #   title:    nil,  # a title for the buffer
      #   data:     nil,  # This field contains all the actual content of the buffer
      #   opts:     nil,  # a list which can store options, such as starting
      #                   # a GUI.Component when the Buffer loads
      # ]
