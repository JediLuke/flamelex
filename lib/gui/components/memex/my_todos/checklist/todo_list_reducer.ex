defmodule Flamelex.GUI.Component.TODOlist.Reducer do
  alias Flamelex.GUI.Component.TODOlist
  alias Flamelex.GUI.Component.TODOdetails
  require Logger

  def process(rdx, :show_todos) do
    rdx
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:full_screen)
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist])
    |> TODOlist.Mutator.refresh_todo_list()
  end

  def process(rdx, {:set_turbo, turbo?}) when is_boolean(turbo?) do
    rdx
    |> TODOlist.Mutator.set_turbo(turbo?)
  end

  def process(rdx, {:open_todo, %Memelex.TidBit{} = t}) do
    rdx
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:split_screen)
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist, TODOdetails])
    |> TODOdetails.Mutator.open_details(t)
  end

  def process(rdx, {:filter_todos, filter_by}) do
    # NOTE: don't even validate here... let it crash in MyTODOs.all(filter: filter_by)
    rdx
    # TODO here, we should update something about the TODOlist state (??), so that the dropdown renders the correct filter
    |> TODOlist.Mutator.set_filter(filter: filter_by)
    |> TODOlist.Mutator.refresh_todo_list()
  end

  def process(rdx, {:refresh_tidbit, _t}) do
    # IO.puts "$$$$$$$$$$$$$$$$$$$ refresh tidbit $$$$$$$$$$$$$$$$$$$"


    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
    |> TODOlist.Mutator.refresh_todo_list()
  end

  def process(rdx, :refresh) do
    rdx
    |> TODOlist.Mutator.refresh_todo_list()
  end

  def process(rdx, :new_todo) do
    # Open the new TODO creation dialog
    rdx
    |> TODOlist.Mutator.set_creating_new_todo(true)
  end

  def process(rdx, :cancel_new_todo) do
    rdx
    |> TODOlist.Mutator.set_creating_new_todo(false)
    |> TODOlist.Mutator.reset_new_todo_form()
  end

  def process(rdx, {:update_new_todo_form, field, value}) do
    rdx
    |> put_in([:apps, :todo_list, :new_todo_form, field], value)
  end

  def process(rdx, :create_todo) do
    # Get the form data
    form = rdx.apps.todo_list.new_todo_form
    
    # Validate form has required data
    if form.title == "" do
      # TODO: Show error message
      rdx
    else
      # Create a new TODO through the memex API
      todo_params = %{
        title: form.title,
        data: form.description,
        tags: [],  # #TODO is automatically added by Memelex.My.TODOs.new
        meta: [
          %{
            "priority" => Atom.to_string(form.priority),
            "status" => "pending"
          }
        ]
      }
      
      # Save to memex
      {:ok, _saved_todo} = Memelex.My.TODOs.new(todo_params)
      
      rdx
      |> TODOlist.Mutator.set_creating_new_todo(false)
      |> TODOlist.Mutator.reset_new_todo_form()
      |> TODOlist.Mutator.refresh_todo_list()
    end
  end
  
  def process(rdx, {:select_todo, todo_uuid}) do
    rdx
    |> put_in([:apps, :todo_list, :selected], todo_uuid)
  end
  
  def process(rdx, {:sort_todos, sort_by}) do
    rdx
    |> TODOlist.Mutator.set_sort_order(sort_by)
    |> TODOlist.Mutator.refresh_todo_list()
  end
  
  def process(rdx, :deselect_todo) do
    rdx
    |> put_in([:apps, :todo_list, :selected], nil)
  end
  
  def process(rdx, {:mark_todo_complete, todo_uuid}) do
    # Find the TODO
    todo = Enum.find(rdx.apps.todo_list.list, fn t -> t.uuid == todo_uuid end)
    
    if todo do
      # Update the TODO status to done in meta field
      updated_meta = case todo.meta do
        [meta_map | rest] when is_map(meta_map) ->
          [Map.put(meta_map, "status", "done") | rest]
        _ ->
          [%{"status" => "done"}]
      end
      
      updated_todo = %{todo | meta: updated_meta}
      {:ok, _saved} = Memelex.My.Wiki.save(updated_todo)
      
      # Refresh the list
      rdx
      |> TODOlist.Mutator.refresh_todo_list()
    else
      rdx
    end
  end
  
  def process(rdx, {:delete_todo, todo_uuid}) do
    # Find and delete the TODO
    todo = Enum.find(rdx.apps.todo_list.list, fn t -> t.uuid == todo_uuid end)
    
    if todo do
      # Mark as deleted
      deleted_todo = %{todo | deleted?: true, deleted_at: DateTime.utc_now()}
      {:ok, _saved} = Memelex.My.Wiki.save(deleted_todo)
      
      # Refresh the list
      rdx
      |> TODOlist.Mutator.refresh_todo_list()
    else
      rdx
    end
  end
end

# defmodule Flamelex.Fluxus.TODOlistReducer do
#   def process(
#         rdx_state,
#         {app, {:set_scroll, scroll}}
#       ) do
#     rdx_state
#     |> Flamelex.GUI.Layers.Layer01.Mutator.set_scroll(app, scroll)
#   end
# end
