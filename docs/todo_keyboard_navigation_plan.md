# Todo List Keyboard Navigation Implementation Plan

## Goal
Add keyboard navigation to the Flamelex todo list component to allow users to navigate and interact with todos without using the mouse.

## Implementation Steps

### 1. Update State Structure
File: `lib/gui/components/memex/my_todos/checklist/todo_list_state.ex`

Add `selected_index` field to track which todo is currently selected:
```elixir
defstruct list: [],
          selected: nil,        # Keep for compatibility
          selected_index: 0,    # NEW: 0-based index of selected todo
          scroll: {0, 0},
          turbo_scroll?: false,
          filter: nil
```

### 2. Extend User Input Handler
File: `lib/gui/components/memex/my_todos/checklist/todo_list_user_input_handler.ex`

Add handlers for:
- `@key_down` / `j` - Move selection down
- `@key_up` / `k` - Move selection up  
- `@key_enter` - Open selected todo
- `@key_space` - Toggle todo completion
- `@key_home` - Jump to first todo
- `@key_end` - Jump to last todo
- `@key_page_down` - Scroll down by page
- `@key_page_up` - Scroll up by page

### 3. Create Selection Mutators
File: `lib/gui/components/memex/my_todos/checklist/todo_list_mutator.ex`

Add functions:
- `select_todo(rdx, index)` - Set selected_index
- `move_selection(rdx, direction)` - Move up/down with bounds checking
- `jump_to_todo(rdx, position)` - Jump to :first or :last
- `ensure_selected_visible(rdx)` - Auto-scroll to keep selection visible

### 4. Update Reducer
File: `lib/gui/components/memex/my_todos/checklist/todo_list_reducer.ex`

Add action handlers:
- `{:select_todo, index}`
- `{:move_selection, :up | :down}`
- `{:jump_to, :first | :last}`
- `{:toggle_todo_status, todo}`
- `{:scroll_by_page, :up | :down}`

### 5. Update Rendering
File: `lib/gui/components/memex/my_todos/checklist/todo_list.ex`

In `render_todo_list/3`:
- Pass selected_index to NeoHyperCard
- Apply highlight style to selected todo
- Ensure selected todo is visible in viewport

### 6. Handle Edge Cases
- Empty list (no selection possible)
- List changes (selection index validation)
- Filtered list (adjust index when filter changes)
- Scroll synchronization with selection

## Testing Strategy

1. Unit tests for mutators and reducers
2. Integration tests using spex
3. Manual testing of all keyboard shortcuts
4. Performance testing with large todo lists

## Success Criteria

- [ ] Can navigate todos with arrow keys
- [ ] Selected todo is visually highlighted
- [ ] Enter opens todo details
- [ ] Space toggles completion status
- [ ] Home/End jump to first/last
- [ ] Page Up/Down scroll by viewport height
- [ ] Selection stays visible when navigating
- [ ] Works with filtered lists
- [ ] No performance degradation

## Code Example

```elixir
# In user_input_handler.ex
def handle(rdx, @key_down) do
  [{TODOlist.Reducer, {:move_selection, :down}}]
end

def handle(rdx, @key_up) do
  [{TODOlist.Reducer, {:move_selection, :up}}]
end

def handle(rdx, @key_enter) do
  case rdx.apps.todo_list do
    %{list: list, selected_index: idx} when idx < length(list) ->
      todo = Enum.at(list, idx)
      [{TODOlist.Reducer, {:open_todo, todo}}]
    _ ->
      :ignore
  end
end
```

## Next Steps

After keyboard navigation is working:
1. Add vim-style shortcuts (h,j,k,l)
2. Implement quick actions (d for delete, n for new)
3. Add search functionality (/)
4. Support multi-select with Shift+arrows