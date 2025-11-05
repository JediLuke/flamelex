# Flamelex Todo System Analysis

## Current Architecture

### Components
1. **TODOlist** (`lib/gui/components/memex/my_todos/checklist/`)
   - `todo_list.ex` - Main Scenic component for displaying todo list
   - `todo_list_state.ex` - State management (list, selected, scroll, filter)
   - `todo_list_reducer.ex` - Actions: show_todos, set_turbo, open_todo, filter_todos
   - `todo_list_mutator.ex` - State mutations
   - `todo_list_user_input_handler.ex` - Keyboard shortcuts (minimal - only Shift for turbo, Escape)

2. **TODOdetails** (`lib/gui/components/memex/my_todos/todo_hypercard/`)
   - Split-screen view for detailed todo editing
   - Appears when a todo is selected from the list

3. **Integration with Memelex**
   - Uses `Memelex.My.TODOs` API for todo management
   - Stores todos as TidBit entities in the memex

### Current Features
- Display todo list with empty state
- Filter by various criteria (tags, priority, overdue, etc.)
- Turbo scroll mode (hold Shift)
- Open todo details in split screen
- Refresh todo list after external changes

### Missing Features (Based on Spex Tests)

1. **Keyboard Navigation**
   - Arrow keys for navigating todos (up/down)
   - Home/End for jumping to top/bottom
   - Page Up/Page Down for scrolling
   - Enter to open todo details
   - Space to toggle todo completion
   - 'd' twice to delete todo
   - 'n' to create new todo
   - '/' for quick search

2. **Todo Management**
   - Create new todos from within the UI
   - Mark todos as done/undone
   - Delete todos
   - Edit todo inline

3. **Advanced Features**
   - Link todos to wiki pages
   - Convert completed todos to journal entries
   - Create todos from selected text
   - Todo templates
   - Smart collections/lists
   - Tag inheritance from parent tidbits
   - Context-aware todo creation (from code comments, etc.)

## Recommended Implementation Plan

### Phase 1: Core Keyboard Navigation
1. Extend `todo_list_user_input_handler.ex` to support:
   - Arrow key navigation
   - Enter to open details
   - Space to toggle completion
   - Basic vim-style navigation (j/k)

2. Add selection tracking to todo_list_state
3. Update renderizer to highlight selected todo

### Phase 2: CRUD Operations
1. Add inline todo creation UI
2. Implement delete functionality
3. Add quick edit mode
4. Support marking todos as done

### Phase 3: Memex Integration
1. Link todos to other tidbits
2. Todo templates
3. Smart collections
4. Context-aware creation

### Phase 4: Advanced Features
1. Search/filter UI
2. Bulk operations
3. Keyboard shortcuts customization
4. Export/import

## Implementation Notes

### State Management
- Todo list state is managed through Fluxus/RadixStore
- Updates flow through reducers and mutators
- UI subscribes to radix_state_change events

### Rendering
- Uses ScenicWidgets.VerticalList for scrollable list
- Each todo is rendered as a NeoHyperCard
- Supports virtual scrolling for performance

### Data Model
- Todos are Memelex.TidBit entities with type "todo"
- Metadata includes priority, due_date, tags
- Links and backlinks for relationships

## Next Steps

1. Start with implementing basic keyboard navigation (Phase 1)
2. Use spex-driven development - write tests first
3. Keep changes minimal and focused
4. Test each feature thoroughly before moving to the next
5. Document new keyboard shortcuts in help system