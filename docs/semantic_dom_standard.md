# Flamelex Semantic DOM Standard

## Overview

The Semantic DOM provides a structured way to annotate Scenic components with metadata that enables AI-driven testing, accessibility features, and enhanced introspection capabilities. This document defines the standard for semantic annotations in Flamelex components.

## Core Principles

1. **Discoverability**: All interactive elements must be discoverable through semantic queries
2. **Clarity**: Semantic metadata should clearly describe the element's purpose and state
3. **Consistency**: Similar components should use consistent semantic patterns
4. **Hierarchy**: Semantic structure should reflect the logical hierarchy of the UI

## Semantic Annotation Structure

Each semantic annotation is a map with the following fields:

```elixir
%{
  # Required fields
  type: atom(),          # Component type identifier
  role: atom(),          # Accessibility role
  label: String.t(),     # Human-readable label
  
  # Optional fields
  description: String.t(),   # Detailed description
  state: map(),             # Current state information
  actions: [atom()],        # Available actions
  clickable: boolean(),     # Is element clickable?
  focusable: boolean(),     # Can element receive focus?
  path: String.t(),         # Hierarchical path
  menu_index: list(),       # Menu navigation index
  has_submenu: boolean(),   # For menu items with children
  value: any(),             # Current value
  children: [String.t()],   # Child element IDs
  parent: String.t()        # Parent element ID
}
```

## Component Types

### Standard Types

- `:button` - Clickable buttons
- `:menu_item` - Menu entries
- `:text_input` - Text input fields
- `:text_area` - Multi-line text areas
- `:checkbox` - Checkboxes
- `:radio_button` - Radio buttons
- `:dropdown` - Dropdown menus
- `:list` - Lists of items
- `:list_item` - Individual list entries
- `:tab` - Tab navigation items
- `:panel` - Content panels
- `:dialog` - Modal dialogs
- `:toolbar` - Tool bars
- `:status_indicator` - Status displays
- `:widget` - Generic widgets
- `:todo_item` - TODO list items
- `:todo_list` - TODO lists

### Custom Types

Components can define custom types prefixed with their module name:
- `:memex_widget`
- `:rapid_selector`
- `:buffer_editor`

## Accessibility Roles

Follow WAI-ARIA role definitions:

- `:button`
- `:menuitem`
- `:menubar`
- `:menu`
- `:textbox`
- `:checkbox`
- `:radio`
- `:listbox`
- `:option`
- `:tab`
- `:tabpanel`
- `:dialog`
- `:toolbar`
- `:status`
- `:application`

## Implementation Guidelines

### 1. Hidden Semantic Elements

Use hidden text elements to carry semantic data:

```elixir
|> Scenic.Primitives.text("",
  id: {:semantic_menu_item, unique_id},
  hidden: true,
  semantic: %{
    type: :menu_item,
    role: :menuitem,
    label: "File",
    clickable: true
  }
)
```

### 2. Component Semantic Registration

Components should register their semantic information in `init/3`:

```elixir
def init(scene, args, opts) do
  semantic_info = %{
    type: :todo_list,
    role: :application,
    label: "TODO List",
    description: "Manage your tasks and todos"
  }
  
  scene = scene |> assign(semantic: semantic_info)
  
  # Register with viewport if available
  if viewport = opts[:viewport] do
    ViewPort.set_semantic(viewport, self(), semantic_info)
  end
  
  {:ok, scene}
end
```

### 3. Pre-rendering Semantic Markers

For dynamic content (like dropdown menus), pre-render all semantic markers:

```elixir
defp render_semantic_menu_tree(graph, menu_map) do
  menu_map
  |> Enum.with_index(1)
  |> Enum.reduce(graph, fn {{type, label, items}, idx}, g ->
    case type do
      :sub_menu ->
        g
        |> add_semantic_marker([idx], label)
        |> render_semantic_submenu(items, [idx])
      _ ->
        g |> add_semantic_marker([idx], label)
    end
  end)
end
```

### 4. State Updates

Update semantic information when component state changes:

```elixir
def handle_cast({:select_item, item_id}, scene) do
  semantic = scene.assigns.semantic
  |> Map.put(:state, %{selected: item_id})
  
  scene = scene |> assign(semantic: semantic)
  
  if viewport = scene.assigns.viewport do
    ViewPort.update_semantic(viewport, self(), semantic)
  end
  
  {:noreply, scene}
end
```

## Query Patterns

### Finding Elements by Type

```elixir
find_semantic_elements(semantic_table, fn elem ->
  elem.semantic[:type] == :button
end)
```

### Finding Elements by Label

```elixir
find_semantic_elements(semantic_table, fn elem ->
  elem.semantic[:label] =~ ~r/Save/i
end)
```

### Finding Clickable Elements

```elixir
find_semantic_elements(semantic_table, fn elem ->
  elem.semantic[:clickable] == true
end)
```

### Finding Menu Items by Path

```elixir
find_semantic_elements(semantic_table, fn elem ->
  elem.semantic[:type] == :menu_item &&
  elem.semantic[:menu_index] == [3, 2]  # Memelex > my TODOs
end)
```

## Best Practices

1. **Always provide labels**: Every interactive element must have a descriptive label
2. **Use consistent naming**: Follow naming conventions for similar elements
3. **Include state information**: Dynamic elements should expose their current state
4. **Maintain hierarchy**: Preserve parent-child relationships in semantic data
5. **Test with queries**: Verify elements can be found through semantic queries
6. **Document custom types**: Add new types to this document when created

## Testing with Semantic DOM

Example spex test using semantic queries:

```elixir
when_ "I find button using semantic DOM", context do
  semantic_elements = query_semantic_dom(%{
    type: :button,
    label: "Save Document"
  })
  
  assert length(semantic_elements) == 1
  button = hd(semantic_elements)
  
  # Simulate click
  send_click_to_element(button)
  
  {:ok, context}
end
```

## Future Enhancements

1. **Semantic Events**: Emit semantic events for state changes
2. **Validation Tools**: Automated semantic annotation validation
3. **Query DSL**: High-level query language for semantic DOM
4. **Accessibility Bridge**: Connect semantic DOM to screen readers
5. **Visual Indicators**: Debug mode showing semantic annotations

## Component Examples

### Button with Semantic Annotation

```elixir
defmodule MyApp.SaveButton do
  use Scenic.Component
  
  def init(scene, args, opts) do
    semantic = %{
      type: :button,
      role: :button,
      label: "Save",
      description: "Save the current document",
      clickable: true,
      actions: [:click, :focus]
    }
    
    scene
    |> assign(semantic: semantic)
    |> push_graph(render(args))
    
    {:ok, scene}
  end
  
  defp render(args) do
    Graph.build()
    |> button("Save", id: :save_button)
    |> text("", 
      id: :semantic_save_button,
      hidden: true,
      semantic: args.semantic
    )
  end
end
```

### TODO Item with Semantic State

```elixir
defmodule MyApp.TodoItem do
  use Scenic.Component
  
  def init(scene, %{todo: todo} = args, opts) do
    semantic = %{
      type: :todo_item,
      role: :listitem,
      label: todo.title,
      description: "TODO: #{todo.title}",
      state: %{
        completed: todo.completed,
        priority: todo.priority
      },
      clickable: true,
      actions: [:toggle, :edit, :delete]
    }
    
    scene
    |> assign(semantic: semantic, todo: todo)
    |> push_graph(render(todo, semantic))
    
    {:ok, scene}
  end
end
```

This standard ensures consistent semantic annotations across all Flamelex components, enabling reliable AI-driven testing and enhanced accessibility features.