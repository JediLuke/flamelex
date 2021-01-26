# Flamelex

A combination text-editor & memex written in Elixir.

Flamelex is a self-contained Elixir app, build upon the Elixir GUI library
`Scenic`. The main inspiration is emacs, especially the idea of having a
REPL that can be personalized. The text-editing experience is also inspired
by Vim.

## Installing Flamelex

### Install Scenic dependencies

As mentioned, we need Scenic. Scenic requires gfx drivers. The most up
to date information on how to install Scenic for your platform can be found
at #TODO

### Running Flamelex from IEx

From the repository, simply start the program in DEV mode, same way you
most likely develop any other elixir program.

```
iex -S mix run
```

This gives you an IEx session, and should have displayed the default
Flamelex window showing a `transmutation circle` and a version number

#TODO insert screenshot

TO get a feel for FLamelex, run some of the following commands:

Transmute.main_circle()
<!-- Transmute.clear() -->

Buffer.load("README")

All editing & processing can be achieved via IEx, including drawing graphics
and all edits of any text, so you can kind of think of it as a shell with
better graphics/feedback - but, we do go a little bit further -> we also
allow inputs into the GUI (mouse clicks / keypresses / etc) to be collected
and then transformed into function calls.

For example, we have a mapping where pressing `e` calls:

Buffer.add_char(buf_id, "e") #TODO

All inputs in Flamelex are simply mappings. We can also use memory, to get
effects such as a leader key. You can press space + c to shift the color
of the transmutation circle, or even to speed it up!



#TODO experiment with making a flamelex alias

## How to use Flamelex

#TODO

### Driving Flamelex via IEx

Flamelex is entirely based upon calling Elixir functions. We do some fancy
magic to make it seem like clicking a button actually performs the action
we want, but really all we are doing is mapping these inputs to functions
& calling them. This means that every single action you can take inside
Flamelex is re-producable via command line.

Some examples:

```
Frame.move(1, left: {10, :px}) # move first frame left 10 pixels
```

How inputs get mapped to these functions is covered in #TODO explain how inputs get mapped to commands

### The Flamelex CommandBuffer #TODO

### The Flamelex MenuBar #TODO

## Basic text editing

### Opening files

Either local, or via HTTP

Ability to open & save files
* extra points - able to open text-only webpages (requires using HTTP c-
  lient to fetch raw text)

### Making basic edits

Ability to perform basic text editing (insertion / deletion / substitut-
    ion)

### Saving files

## Command mode

Ability to execute commands via IEx and/or the command buffer


Ability to Load "environments" (saved config/data-store/knowledge-base/
    organizer)

### Recording macros

When we press a key, we record it - but when it comes to actions, we don't
record keystrokes. When we record a macro, we store a list of all the
functions that got called, and then we replay them.

This is a great way of creating new functionality - we can construct programs
easily this way, simply by doing the action.

## Memex

The Memex is heavily inspired by Tiddlywiki

### Listing the feed

### Creating a new note

## Agents

Flamelex has the built-in concept of agents

### Setting reminders

How to set a reminder using the Remidner agent...

## Goals of the project

Franklin was born out of my frustration trying to create the "perfect"
emacs/vim setup. I am a heavy modifier of these programs, but eventually
hard to use APIs and bugs in the software (I consider emacs' inability
to support multi-threading a bug in 2020) prompted me to "flip the desk"
and start from scratch. I chose Elixir because it is a language I know
and love, and because I think the immutable, functional style of Elixir
code, as well as the fact it runs on the BEAM VM, will make Franklin a
very stable editor.

Some of my main goals are:

* Easy for beginners. Comes with tutorial, full help, and good UX (alwa-
  ys give the user feedback!)
* Self-documenting
* Contains a personal memex, modelled on tiddlywiki
* REPL driven for absolute programmability
* modal-editing, but with inputs completely de-coupled from functionality

## The flamelex architecture

flamelex used the `flux` architecture - we hold a store of state, and
use reducer functions, combined with actions/input (and they are capable
of generating side-effects, such as firing of other actions), to generate
the updated state - which is then rendered.

### Flamelex.Fluxus



### Handling user input

User input gets picked up by the underlying Scenic drivers, and Scenic
then sends that input as a message to the process which is rendering
the root scene - see `Flamelex.GUI.RootScene`.

Inside `Flamelex.GUI.RootScene` there is a function, `handle_input/3` -
this is where user-input is presented to us by Scenic. That's just how
Scenic works, keypresses show up here first. But we don't want to hold
our application state inside Scenic really, since we want to keep drawing
the GUI decoupled from the actual business-logic of editing text. So we
just immediately forward this user input to the Fluxus part of the app,
by calling `Flamelex.Fluxus.handle_user_input(input)`

when a user presses a key...
-> `Flamelex.GUI.RootScene.handle_input/3` (root_scene.ex)
  -> `Flamelex.Fluxus.handle_user_input/1` (fluxus.ex)
    -> `Flamelex.FluxusRadix` receives `{:user_input, ii}` via `Genserver.cast` (fluxus_radix.ex)
      -> calls `Flamelex.Fluxus.UserInputHandler.handle/2` (user_input_handler.ex)
        -> spins up a new `Task` process, executing
          `lookup_action_for_input_async/2` under `Input2ActionLookup.TaskSupervisor`
          -> that function will look in the key-mapping module, e.g.
             `Flamelex.API.KeyMappings.VimClone` if this lookup fails/crashes,
             no problem really. If a lookup is successful, then maybe
             actions get fired, functions get called... whatever.

### The `franklin_dev` branch

#TODO Explain about Franklin

## Backlog / TODOs

* Ability to read documents & maintain my own notes on such documents
* Ability to do source-control inside the editor
* Integrated with Elixir compiler
* add MenuBar which is linked to calling functions
& ability to read & search HexDocs

NEXT is MenuBar

