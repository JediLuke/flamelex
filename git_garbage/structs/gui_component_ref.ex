defmodule Flamelex.GUI.Structs.GUiComponentRef do
  @moduledoc """
  Points to a Gui component in Flamelex - but it isn't the component
  itself! Just a reference to one.
  """
  use Flamelex.{ProjectAliases, CustomGuards}


  defstruct [
    ref:        nil,  # a unique reference, used to register the buffer process, eg. {:file, "some/filepath"} or "lukesBuffer"
    # number:     nil,  # if we want to give buffers numbers, ie. to order them
    # type:       nil,  # tells us if its a text buffer or whatever
    # label:       nil,  # a short name for the buffer, doesn't have to be unique
    # title:      nil,  # an optional title, for displaying in window bars etc
    # tags:       [],   # a list of tags... this is for the future
  ]


  def new(%{ref: r} = _params) do
    %__MODULE__{
      ref: r,
    }
  end

  @doc """
  This is the tag used to register process.. You can also pass it a map,
  & it will either return the rego_tag matching the params, or `:error`
  """
  #TODO deprecate first...
  # def rego_tag(%BufRef{ref: ref}) do
  #   {:gui_component, ref}
  # end
  # def rego_tag(:gui_component, ref: r) do
  #   {:gui_component, r}
  # end
  # def rego_tag({:gui_component, %BufRef{ref: ref}}) do
  #   {:gui_component, ref}
  # end
  def rego_tag(_else), do: :error
end
