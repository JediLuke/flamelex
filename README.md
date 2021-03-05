# warning - you are on the branch `franklin_dev`

flamelex is currently considered `alpha` - not stable or usable by the
general public.

During the alpha phase of development (~Dec 2019 - ??), the branch name
changed several times, but it was actually just a continuous series of
commits from a single developer (JediLuke). This branch has been kept for
archaelogical reasons - once `v0.2.7-alfonz` has been officially released,
the default branch will revert to `trunk`, and development will move over
to the `jediluke/develop` branch.

## TODOs

* update instructions about loading in a Memex
* show popup to new users

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
in the [Scenic documentation](https://hexdocs.pm/scenic/install_dependencies.html)

### Running Flamelex from IEx

From the repository, simply start the program in DEV mode, same way you
most likely develop any other elixir program.

```
iex -S mix run
```

This gives you an IEx session, and should have displayed the default
Flamelex window showing a "transmutation circle" and a version number

#TODO insert screenshot

To get a feel for FLamelex, run some of the following commands:

Buffer.open!("README")

#TODO Transmute.main_circle()

All editing & processing can be achieved via IEx, including drawing graphics
and all edits of any text, so you can kind of think of it as a shell with
better graphics/feedback - but, we do go a little bit further -> we also
allow inputs into the GUI (mouse clicks / keypresses / etc) to be collected
and then transformed into function calls.

#TODO example

All inputs in Flamelex are simply mappings. We can also use memory, to get
effects such as a leader key. You can press space + c to shift the color
of the transmutation circle, or even to speed it up!

#TODO experiment with making a flamelex alias

## Adjusting the window size

#TODO

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
Buffer.open!
#TODO Frame.move(1, left: {10, :px}) # move first frame left 10 pixels
```

How inputs get mapped to these functions is covered in #TODO explain how inputs get mapped to commands

#### using the API modules

The way it works is this - users should only need to use the API to achieve
what they want to do. If this isn't the case, then adding this functionality
is not difficult, but it needs to be added in a way that's consistent with
how flamelex works.

The API can call directly into the underlying sub-tree for information
requests, e.g. Buffer.list calls BufferManager, but to trigger actions,
it should only call `Flamelex.Fluxus.fire_action/2`

Then, these actions will go through Fluxus and eventually propagate through
to the reducer. Then, in the reducers, *that's* where you can call things
like Buffer.move_cursor, etc.

The unguarded nature of Elixir modules is both a strength and a weakness,
and overall I prefer to be given the freedom to build amazing things with
some gotchas, rather than be forced to jump through unnecessary hoops that
just get in the way once I know what I'm doing - but this is a gotcha for
adding code to Flamelex, you *must* go through the designated flows. If you
start calling things like Buffer.move_cursor(2), it will probably work,
but your whole state tree might get out of whack...

### The Flamelex KommandBuffer #TODO

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

What is a Memex? see: https://en.wikipedia.org/wiki/Memex

Think of the Memex as your personal wikipedia. It's a place to store all
your knowledge and data, in a way that's retreivable and programmable
(in Elixir no less!). In the Memex, you can store:

* Your favourite Elixir snippets
* Your wife's birthday
* Your latest beyond-brisket recipe
* Financial records
* kanban boards
* ...
* anything...

#TODO Example

iex> Memex.My.current_timezone()
"Texas" #TODO
iex> Memex.random_quote().text
"Well done is better than well said."

The Memex is heavily inspired by Tiddlywiki.

### Creating your own Memex environment

#TODO
Flamelex must be configured with a Memex?
Flamelex will look for a Memex?

### Showing the memex-feed

#TODO it looks like Tiddlywiki

### Creating a new tidbit

#TODO

## Agents

Flamelex has the built-in concept of agents

### Setting reminders

How to set a reminder using the Remidner agent...

## Goals of the project

Flamelex was born out of my frustration trying to create the "perfect"
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
          `lookup_action_for_input_async/2` under `InputHandler.TaskSupervisor`
          -> that function will look in the key-mapping module, e.g.
             `Flamelex.API.KeyMappings.VimClone` if this lookup fails/crashes,
             no problem really. If a lookup is successful, then maybe
             actions get fired, functions get called... whatever.

### The `franklin_dev` branch

*warning - you are on the branch `franklin_dev`*

This software's first working name was `Franklin`, after the American
philosopher, inventor, and I suspect alchemist, Benjamin Franklin.
I was learning a lot about American history at the time, and when looking
for a good quote to initialize the branch, came across the apocryphal
quip that graces the git-log of the first commit:

“For every minute spent organizing, an hour is earned.” - Benjamin Franklin
JediLuke on 12/28/2019, 11:49:22 PM

At some point I began throwing the name out there to some other programmers,
and got feedback that `frankin` was too generic, there were other packages
in other languages that already used it, etc... I had already gotten very
into the alchemist theme by this point, so decided to change the name to
`flamelex` after the famous alchemist, Nicholas Flamel.

The first flamelex release, `v0.2.7-alfonz` was beginning to become finalized
around the start of 2021. Up until this point, all work was just one series of
commits by me, JediLuke. I decided to keep this series of commits as the
branch `franklin_dev`, as a tip-o'-the-hat to Franklin, the original seed
that grew into Flamelex. Any code archaelogists out there?? here's a dig!

## Backlog / TODOs

* Ability to read documents & maintain my own notes on such documents
* Ability to do source-control inside the editor
* Integrated with Elixir compiler
* add MenuBar which is linked to calling functions
& ability to read & search HexDocs

NEXT is MenuBar

