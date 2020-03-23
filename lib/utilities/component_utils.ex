defmodule Utilities.ComponentUtils do
  #TODO delete??

  @doc ~s(Looks in a Scene or Components `component_ref` list and finds the component matching this reference.)
  def find_component_reference_pid!(component_ref, reference) when is_list(component_ref) do
    {^reference, pid} =
        component_ref
        |> Enum.filter(
            fn {^reference, _pid} -> true
               _else              -> false
            end)
        |> List.first

    pid
  end
end
