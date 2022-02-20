# Adding a new input & command

1) define the action
2) define a reducer function, which can handle the action
3) make this action available, via the API
4) bind that API call to an input via a key-mapping

  # The process of adding functionality

  ## 1) Create an API function e.g. Buffer.switch(b)
  ## 2) Probably, it fires an action to FluxusRadix

<!-- 
This is the "flow"

```
incoming_input
|> GUI.Scene.Root.handle_input/3
|> GUI.Input.EventHandler.process/2
|> GUI.Root.Reducer.process/2                  # propagate actions by sending messages to registered child components
|> ChildComponent.handle_cast({:action, a})   # handles incoming actions in same fashion
``` -->

## Capturing input

Input is captured by Scenic in the root Scene. This is `root.ex`. See
the `handle_input/3` function. We forward this to `GUI.Input.EventHandler`.

Scenic codes the inputs for us, but to make the code more legible, I put
then all in the `GUI.ScenicInputEvents` module. Import this module and
always use the module attribute bindings.
