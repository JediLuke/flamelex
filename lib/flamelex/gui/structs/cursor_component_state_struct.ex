defmodule Flamelex.Buffer.Structs.TextCursorState do


  # defstruct [
  #   num:
  #   position:
  # ]

end

# defmodule Flamelex.Structs.BufRef do
#   @moduledoc """
#   Points to a Buffer in Flamelex - but it isn't the buffer itself! Just a
#   reference to one.
#   """
#   use Flamelex.{ProjectAliases, CustomGuards}


#   @valid_buffer_types [Flamelex.Buffer.Text]


#   # defstruct [
#   #   num:
#   #   position:



#   # ]


#   # @doc """
#   # This is the tag used to register buffer processes. You can also pass it
#   # a map, & it will either return the rego_tag matching the params, or `:error`
#   # """
#   # def rego_tag(%__MODULE__{ref: ref}), do: rego_tag(ref)
#   # def rego_tag(%{ref: ref}), do: rego_tag(ref)
#   # def rego_tag(%{file: path}) when is_bitstring(path), do: rego_tag({:file, path})
#   # def rego_tag({:file, path} = tag) when is_bitstring(path) do
#   #   {:buffer, tag}
#   # end
#   # def rego_tag(_else), do: :error

#   # def is_valid_ref?({:file, path}) when is_bitstring(path), do: true
#   # def is_valid_ref?(s) when is_bitstring(s), do: true
#   # def is_valid_ref?(_ref), do: false

# end
