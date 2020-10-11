# Adding a new input & command

The short version is:

* Write a function in `GUI.Input.EventHandler` matching your desired input
* Inputs get translated into actions, processed b the `Root.Reducer`
* The `Root.Reducer` will propagate actions to child components if needed,
  using PIDs in the `RootScene` (components register themselves upon init)
* `Root.Reducer` can update the `RootScene`, causing it to push a new graph
* `Scenic.Components` which have actions propagated to them can do the same,
  perhaps moving the logic into their own `Reducer`, or just `handle_cast`
* The component, having processed this action, will push a new graph

This is the "flow"

```
incoming_input
|> GUI.Scene.Root.handle_input/3
|> GUI.Input.EventHandler.process/2
|> GUI.Root.Reducer.process/2                  # propagate actions by sending messages to registered child components
|> ChildComponent.handle_cast({:action, a})   # handles incoming actions in same fashion
```

## Capturing input

Input is captured by Scenic in the root Scene. This is `root.ex`. See
the `handle_input/3` function. We forward this to `GUI.Input.EventHandler`.

Scenic codes the inputs for us, but to make the code more legible, I put
then all in the `GUI.ScenicInputEvents` module. Import this module and
always use the module attribute bindings.

### Event handler

Event handler takes input & processes it. It may use the history of previous
commands to do so. This is the first real edit we have to make.

Add a new function which matches on the Root state, and the input you
are adding functinality for:

```
  def process(%{command_buffer: %{visible?: true}} = state, input) when input in @valid_command_buffer_inputs do
    Scene.action({'COMMAND_BUFFER_INPUT', input})
    state |> add_to_input_history(input)
  end
```

Usually the handling here involves invoking an action, which will be
applied by either the Root reducer, or one of the other component reducers.
If it is a component reducer, you can look in the Root state to get the
pid of that component (callback registration mechanism is explained
somewhere else)

## 

## Reducer

The Event handler will most likely cast an action to a reducer. The reducer
processes these actions, usually by returning a tuple with a new state and
a new graph

```
  {new_state, new_graph}
```

## Updating the GUI & component state

Whether the action was handled directly inside the component (probably
using pattern-matching), or was outsourced to a `Reducer` module (which
will also use pattern matching, but for large components it's nice to
have a separate reducer to put all this log into) - the component will
push a modifid graph & update it's own state, then enter the message
processing loop again ready to receive a new action.