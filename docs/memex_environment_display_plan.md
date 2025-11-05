# Memex Environment Display & Navigation Plan

## User Journey Goal
When a user boots Flamelex with a memex environment:
1. They should immediately see which environment they're in
2. They should be able to navigate to TODOs via menubar
3. The experience should be smooth and flicker-free

## Implementation Tasks

### 1. Display Memex Environment Name

**Location Options:**
- Top-right corner of the window (like a status indicator)
- In the window title bar
- As part of a status bar at the bottom
- In the menubar itself

**Recommended: Top-Right Status Widget**

Create a new component: `lib/gui/components/memex_env_indicator.ex`

```elixir
defmodule Flamelex.GUI.Components.MemexEnvIndicator do
  use Scenic.Component
  alias Scenic.Graph
  
  def validate(data), do: {:ok, data}
  
  def init(scene, _args, _opts) do
    state = Flamelex.Fluxus.RadixStore.get()
    
    graph = render(state)
    
    scene = scene
    |> assign(state: state)
    |> push_graph(graph)
    
    # Subscribe to state changes
    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
    
    {:ok, scene}
  end
  
  defp render(%{memex: %{env: %{name: env_name}}}) do
    # Position in top-right corner
    Graph.build()
    |> Graph.add_to_graph(
      Scenic.Primitives.group(
        fn g ->
          g
          |> Scenic.Primitives.rect({200, 30}, 
            fill: {:linear, {0, 0, 200, 0, :dark_slate_blue, :slate_blue}},
            translate: {-220, 10})
          |> Scenic.Primitives.text("📁 #{env_name}",
            fill: :white,
            font_size: 16,
            translate: {-200, 28})
        end,
        translate: {:viewport_width, 0}  # Anchor to right edge
      )
    )
  end
  
  defp render(_no_memex) do
    Graph.build()  # Empty graph when no memex
  end
end
```

### 2. Fix Menubar Flickering

**Potential Causes:**
- Rapid re-rendering on mouse movement
- State updates triggering full redraws
- Hover state management issues

**Solutions:**
1. Implement render diffing/caching
2. Debounce mouse movement events
3. Use Scenic's built-in dirty region tracking
4. Separate hover state from main component state

### 3. Improve Menu Navigation

**Current Issues:**
- Coordinate-based clicking is fragile
- No keyboard navigation support
- Menu items don't have stable positions

**Solutions:**

#### A. Add Semantic IDs to Menu Items
```elixir
# In menubar component
|> Scenic.Primitives.text("My TODOs",
  id: :menu_item_my_todos,
  translate: {x, y})
```

#### B. Create Menu Navigation Helper
```elixir
defmodule Flamelex.TestHelpers.MenuNavigator do
  @menu_items %{
    file: {50, 15},
    edit: {100, 15},
    memex: {200, 15},
    # ... etc
  }
  
  @dropdown_items %{
    my_todos: {0, 60},  # Relative to menu position
    my_wiki: {0, 90},
    # ... etc
  }
  
  def click_menu(menu_name) do
    {x, y} = @menu_items[menu_name]
    ScenicMcp.Probes.send_mouse_click(x: x, y: y)
  end
  
  def click_menu_item(menu_name, item_name) do
    {menu_x, menu_y} = @menu_items[menu_name]
    {offset_x, offset_y} = @dropdown_items[item_name]
    
    ScenicMcp.Probes.send_mouse_click(
      x: menu_x + offset_x,
      y: menu_y + offset_y
    )
  end
end
```

### 4. Add Keyboard Shortcuts

**Implement Global Keyboard Shortcuts:**
- `Cmd/Ctrl + Shift + T` - Open TODOs
- `Cmd/Ctrl + Shift + W` - Open Wiki  
- `Cmd/Ctrl + Shift + J` - Open Journal

```elixir
# In root scene input handler
def handle_input({:key, {:key_t, 1, [:cmd, :shift]}}, _context, state) do
  Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
  {:noreply, state}
end
```

### 5. Semantic DOM Integration

**Phase 1: Basic Implementation**
1. Each component registers semantic info in ETS
2. Include component type, ID, text content, bounds
3. Create query interface for tests

```elixir
defmodule Flamelex.GUI.SemanticRegistry do
  def register(component_id, %{
    type: :menu_item,
    text: "My TODOs",
    bounds: {x, y, w, h},
    action: {:show_todos}
  })
  
  def find_by_text(text) do
    # Query ETS table
  end
  
  def find_by_type(type) do
    # Query ETS table
  end
end
```

### 6. Environment Safety Features

**Prevent Accidental Production Writes:**
1. Color-code environments (red=prod, blue=dev, green=test)
2. Add confirmation dialogs for destructive actions in prod
3. Show environment in window title
4. Add read-only mode option

## Testing Strategy

1. **Visual Regression Tests**
   - Screenshot comparisons
   - Ensure env indicator is visible
   - Verify menu renders correctly

2. **Navigation Tests**
   - Test all paths to TODOs page
   - Verify keyboard shortcuts
   - Test menu clicking

3. **Environment Tests**
   - Test with different memex environments
   - Test without memex
   - Test environment switching

## Success Criteria

- [ ] Environment name is always visible when memex is active
- [ ] Can navigate to TODOs via menubar without flicker
- [ ] Keyboard shortcuts work reliably
- [ ] Tests can find and click menu items semantically
- [ ] Clear visual distinction between environments
- [ ] Smooth, professional user experience

## Implementation Order

1. Add environment indicator (quick win)
2. Fix menubar flickering (improves UX)
3. Add keyboard shortcuts (improves navigation)
4. Implement semantic helpers (improves testing)
5. Full semantic DOM (long-term goal)