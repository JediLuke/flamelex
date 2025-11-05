# Adding the Memex Environment Indicator

## Quick Integration Guide

To add the memex environment indicator to Flamelex, you need to add it to the root scene.

### 1. Add to Root Scene

In `lib/scenes/flx_root_scene.ex` (or wherever your root scene is defined), add the component:

```elixir
# In your init or render function
graph
|> Flamelex.GUI.Components.MemexEnvIndicator.add_to_graph([
  viewport_width: viewport_width
])
```

### 2. Ensure State Updates

The component automatically subscribes to `:radix_state_change` events, so it will update when the memex environment changes.

### 3. Styling Customization

The component uses different colors for different environments:
- **Blue** - Development environments
- **Green** - Test environments  
- **Red** - Production environments
- **Purple** - Default/other environments

### 4. Testing the Indicator

```elixir
# In IEx, you can test by checking the current environment
Flamelex.Fluxus.RadixStore.get().memex.env.name

# The indicator should show this name in the top-right corner
```

### 5. Optional Enhancements

1. **Click Handler**: The component includes a click handler that could show more details:
   ```elixir
   def process(rdx, {:show_env_details, env}) do
     # Show a popup with:
     # - Full environment name
     # - Memex directory path
     # - Active agents
     # - Environment statistics
   end
   ```

2. **Hover Effect**: Add hover state to show it's interactive:
   ```elixir
   def handle_input({:cursor_enter, _}, _context, scene) do
     # Brighten the background color
   end
   ```

3. **Animation**: Fade in when environment loads:
   ```elixir
   # Use Scenic animations to fade in the indicator
   ```

## Benefits

1. **Always Visible** - Users always know which environment they're in
2. **Color Coded** - Quick visual distinction between dev/test/prod
3. **Non-Intrusive** - Small, out of the way in top-right corner
4. **Responsive** - Updates automatically when environment changes

## Next Steps

After adding the basic indicator:
1. Add the popup for detailed environment info
2. Add keyboard shortcut to toggle visibility
3. Save user preference for showing/hiding indicator
4. Add environment switching capability