defmodule Flamelex.GUI.Component.TODOlist.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  @default_filter {:top_priority, 25}

  def refresh_todo_list(%RadixState{} = rdx) do
    todo_list =
      if is_nil(rdx.apps.todo_list.filter) do
        Memelex.My.TODOs.all(filter: @default_filter)
      else
        Memelex.My.TODOs.all(filter: rdx.apps.todo_list.filter)
      end

    # Apply sorting if specified
    sorted_list = apply_sort_order(todo_list, rdx.apps.todo_list.sort_order)

    rdx |> put_in([:apps, :todo_list, :list], sorted_list)
  end

  # def refresh_todo_list(%RadixState{} = rdx, filter: f) do
  #   todo_list = Memelex.My.TODOs.all(filter: f)
  #   rdx |> put_in([:apps, :todo_list, :list], todo_list)
  # end

  def set_turbo(%RadixState{} = rdx, turbo?) when is_boolean(turbo?) do
    put_in(rdx, [:apps, :todo_list, :turbo_scroll?], turbo?)
  end

  def set_filter(%RadixState{} = rdx, filter: f) do
    # NOTE I guess it's a touch *dangerous* not validating
    # the filter here, but we do validation inside the reducer,
    # adding further validation here is redundant and slows us down...

    # Since writring that ^^ comment, I have _also_ removed validation
    # from the reducer! We just assume the filter is valid, until it gets
    # propagated to My.TODOs and crashes !!?!

    # If we do add validation, do it right at the end, cause it's a lot of refactoring all the time right now having so much validation
    put_in(rdx, [:apps, :todo_list, :filter], f)
  end

  def set_creating_new_todo(%RadixState{} = rdx, creating?) when is_boolean(creating?) do
    put_in(rdx, [:apps, :todo_list, :creating_new_todo?], creating?)
  end

  def reset_new_todo_form(%RadixState{} = rdx) do
    put_in(rdx, [:apps, :todo_list, :new_todo_form], %{title: "", description: "", priority: :medium})
  end
  
  def set_sort_order(%RadixState{} = rdx, sort_order) do
    put_in(rdx, [:apps, :todo_list, :sort_order], sort_order)
  end
  
  # Private helper to apply sorting
  defp apply_sort_order(todos, :default), do: todos
  
  defp apply_sort_order(todos, :priority_high) do
    # Sort by priority: high -> medium -> low
    Enum.sort_by(todos, fn todo ->
      priority = get_todo_priority(todo)
      case priority do
        "high" -> 1
        "medium" -> 2
        "low" -> 3
        _ -> 4  # No priority items go last
      end
    end)
  end
  
  defp apply_sort_order(todos, :priority_low) do
    # Sort by priority: low -> medium -> high
    Enum.sort_by(todos, fn todo ->
      priority = get_todo_priority(todo)
      case priority do
        "low" -> 1
        "medium" -> 2
        "high" -> 3
        _ -> 4  # No priority items go last
      end
    end)
  end
  
  defp apply_sort_order(todos, :date_newest) do
    # Sort by creation date, newest first
    Enum.sort_by(todos, fn todo ->
      todo.created
    end, {:desc, DateTime})
  end
  
  defp apply_sort_order(todos, :date_oldest) do
    # Sort by creation date, oldest first
    Enum.sort_by(todos, fn todo ->
      todo.created
    end, {:asc, DateTime})
  end
  
  defp get_todo_priority(todo) do
    case todo.meta do
      [%{"priority" => priority} | _] -> priority
      _ -> nil
    end
  end
end
