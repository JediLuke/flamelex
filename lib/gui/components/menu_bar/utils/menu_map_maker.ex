defmodule Flamelex.GUI.Components.MenuBar.MenuMapMaker do
  @doc """
  Return a list of all the zero-arity functions in a module, in
  the correctly formatted list of `{label, function}` tuples for
  injecting into a `Flamelex.GUI.Components.MenuBar` menu-map.
  """
  def zero_arity_functions("Elixir." <> module_name) when is_bitstring(module_name) do
    # NOTE: Because we automatically add Elixir. to the start of the module
    # (which we need to do in order to get `String.to_atom` to convert it
    # cleanly into a proper module name), we need to also strip it out
    # first if it already exists to cover all cases :facepalm:
    zero_arity_functions(module_name)
  end

  def zero_arity_functions(module_name) when is_bitstring(module_name) do
    ("Elixir." <> module_name)
    |> String.to_atom()
    |> zero_arity_functions()
  end

  def zero_arity_functions(module) when is_atom(module) do
    module.__info__(:functions)
    |> Enum.filter(fn {_exported_fn, arity} -> arity == 0 end)
    |> Enum.map(fn {exported_fn, _arity = 0} -> exported_fn end)
    |> Enum.map(fn exported_fn ->
      {Atom.to_string(exported_fn),
       fn ->
         # NOTE: When we execute one of these zero-arity functions,
         # it happens within the context/process of the MenuBar.
         # This means that any zero-arity function which is designed
         # to return an item (usually for use in the CLI) will return
         # that item, and it will get swallowed inside this context,
         # effectively achieving nothing. I put this IO.inspect here
         # so that we can at least see the results on the CLI even it
         # we can't use them.
         apply(module, exported_fn, [])
         |> IO.inspect(label: "#{Atom.to_string(exported_fn)}")
       end}
    end)
  end

  @doc """
  Construct a tree of zero-arity functions grouped by their modules,
  including constructing nested sub-menus based on a typical namespacing
  convention for Elixir modules. Returns a correctly formatted list of
  sub-menus (in the form `{:sub_menu, label, menu}`) and zero-arity
  functions (in the form `{label, function}`) for building sub-menu trees
  that can be injected into a `Flamelex.GUI.Components.MenuBar` menu-map.

  To filter from the list of all possible modules, we have to give it
  a string which is what all the modules in the sub-menu tree start with,
  e.g. "Elixir.Flamelex.API"

  Note that this function only works with Elixir modules, not Erlang ones.
  """
  def modules_and_zero_arity_functions(modules_start_with)
      when is_bitstring(modules_start_with) do
    split_base_module = Module.split(modules_start_with)
    base_depth = Enum.count(split_base_module)

    modules =
      :code.all_available()
      |> Enum.map(fn {module, _filename, _loaded?} -> module end)
      |> Enum.filter(fn module -> String.starts_with?("#{module}", modules_start_with) end)
      |> Enum.map(&to_string(&1))

    split_modules =
      modules
      |> Enum.map(&Module.split(&1))

    # get all the sub-menus in the level below this one
    {_module_depth, top_lvl_sub_menu} =
      split_modules
      |> Enum.group_by(&Enum.count(&1))
      |> Enum.find(fn {depth, _sub_menu} -> depth == base_depth + 1 end)

    sub_menu_tree_result =
      top_lvl_sub_menu
      |> Enum.map(&calc_lower_sub_menu(&1, split_modules))
      |> Enum.reject(&(&1 == :no_children))

    # NOTE: we check this cause we don't want to call `zero_arity_functions(modules_start_with)`
    # if the module doesn't exist, or it will crash!
    if Enum.member?(modules, modules_start_with) do
      sub_menu_tree_result ++ zero_arity_functions(modules_start_with)
    else
      # no need to get extra functions from the base module, just return the sub-menus
      sub_menu_tree_result
    end
  end

  def calc_lower_sub_menu(top_item, modules) do
    next_depth = Enum.count(top_item) + 1
    # convert a list like ["Module", "By", "Luke"] to a string, "Module.By.Luke"
    module_name = Enum.reduce(top_item, fn x, acc -> acc <> "." <> x end)

    # NOTE: It's this step which causes the recursion to bottom-out.
    # the increasing size of the sub-modules means we eventually
    # get an empty list when we filter on items which are a level deeper
    sub_modules =
      modules
      |> Enum.filter(&(Enum.count(&1) == next_depth))
      |> Enum.filter(fn l -> List.starts_with?(l, top_item) end)

    this_sub_menu =
      Enum.map(sub_modules, fn sub_mod ->
        calc_lower_sub_menu(sub_mod, modules)
      end)
      |> Enum.reject(&(&1 == :no_children))

    these_zero_arity_functions = zero_arity_functions(module_name)

    if this_sub_menu == [] and these_zero_arity_functions == [] do
      :no_children
    else
      label = List.last(top_item)
      {:sub_menu, label, this_sub_menu ++ these_zero_arity_functions}
    end
  end
end
