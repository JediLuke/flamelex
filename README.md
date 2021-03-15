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

From the repository, simply start the program in `dev` mode, the same way
you would start basically any Elixir program using Mix:

```
iex -S mix run
```

This gives you an IEx session, and should have displayed the default
Flamelex window showing a "transmutation circle" and a version number:

#TODO insert screenshot

Now, of course Flamelex responds to keypresses - it is a text-editor after
all. Butto get a feel for how the software works, we are going to start
by just running some more commands in IEx. Flamelex was designed first and
foremost as a GUI extension of the Elixer CLI, IEx, so understanding that
under the hood, everything is just functions, is one of the key stepping
stones to becoming proficient with Flamelex.

Go back to the IEx terminal you used to start flamelex, and type:

```
Buffer.open!("README")
```

You should see a new Buffer open - if you are coming from a Vim or Emacs
background, Buffers are exactly what you expect them to be - a window into
a data-stream, usually a text-file, which lets you inspect and modify the
contents of that data stream (or just, Buffer == file, for the simpletons).

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

## Getting Started

### TL:DR; Up and Running in 5 minutes

The first window is just a blank window showing the background. To do
something useful, we need to open a `Buffer`. We can do this a few ways:

* Click a MenuBar option #TODO
* Put it in CLI

We shall use the CLI for now:

```Buffer.open()```

#TODO explain the rest

### Adjusting the window size

Right now, because of the way Scenic works, we have to re-draw the gui
if we want to resize the window. The way we do this, is to change the
value of the GUI dimensions in the `Flamelex.GUI.ScenicInitialize` (or,
the `scenic_initialize.ex` file, same thing)

Fine the `default_viewport_config`, declared at the top, and update the
`size` key to a tuple. This is the number of pixels (citation needed) in
the new window. Restart Flamelex and voila, it should be the new size.

Note that right now, all objects in the GUI are hard-coded in size, so
adjusting the size of the window may make things render stragely. In the
future, we want to look to incorporating the [Layout-o-Matic!](https://github.com/BWheatie/scenic_layout_o_matic)
library to get flexible sizes/layouts.

### Driving Flamelex via IEx

Flamelex is entirely based upon calling Elixir functions. We do some fancy
magic to make it seem like clicking a button actually performs the action
we want, but really all we are doing is mapping these inputs to functions
& calling them. This means that every single action you can take inside
Flamelex is re-producable via command line.

Some examples:

```
Buffer.list() # will return nothing because, no buffers open
[]
b = Buffer.open!
b
{:file, blah} # so, this is a reference
Buffer.list()
# this will now show a list with the new buffer in it

#TODO Frame.move(1, left: {10, :px}) # move first frame left 10 pixels

```

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

When developing or changing the functionality of the API, remember to respect
the rest of Flamelex as a *seperate system*, so we can't just reach into
the internals (even though Elixir would let us do that), because that's
going to start screwing things up! e.g. to implement `Buffer.open`, we
must never call up BufferManager and directly request the Buffer be opened -
this breaks a whole chain of checks & event-triggers, starting way back
up at FluxusRadix. We don't just directly affect Flamelex, we instead
use the mechanism of firing actions, which correctly processes the input
and propagates it through the internal messaging infrastructure of Flamelex.

### The Flamelex KommandBuffer #TODO

The KommandBuffer is the flamelex version of `M-x` (execute-extended-command)
in emacs. It brings the terminal directly into your editing experience.

The iex console is quite powerful, capable of storing variables and running
basically any Elixir code. In many ways, flamelex is just a GUI wrapper
around the iex shell, with some libraries around editing text thrown in.
Flamelex was, from the ground up, intended to work like emacs in the sense
that it is an interactive lisp shell, with a runtime of variables (though
in our case, we like to back it up to disk) and functions, including functions
which can edit text files.

historical note: The day I thought I had become an emacs convert for life,
was the day I discovered `M-x` or `execute-extended-command`. This command
in emacs brings up a lisp repl, right over your text files! I was a heavy
user of this feature, and I wrote many personal shortcut functions, which
were naturally all accessible via the `M-x` shell. I liked this command
so much, that I re-mapped it to <leader>k, which is IMHO the most
ergonomic and efficient leader keymapping - it earned that spot, because
I used it so often.

THe first way to activate the KommandBuffer is, of course, by calling
the appropriate function in iex. In this case we call:

```
KommandBuffer.show()
```

You may notice, that an input has appeared at the bottom of the screen:

#TODO show screenshot

Here, you can type in any Elixir command you like - it's not really any
different from typing it into iex.

#TODO show example of, typing a function into iex, and typing one into KommandBuffer

Now, we don't really want to have to go use iex each time we want to use
the KommandBuffer - that would kind of defeat the point. Instead, we can
map this function call to some keypresses, so we can activate the KommandBuffer
with some simple keystrokes.

When I implemented this feature in flamelex, I immediately mapped it to
<leader>k again, which is how it ended up with the nomenclature of
`KommandBuffer`

This mapping is completely arbitrary! As demonstrated earlier, you can
just as easily open the KommandBuffer by calling the function in iex, as
by pressing this, completely arbitrary, combination of keypresses. This
is just the default ones that *I* like to use, because I use this feature
a lot, and <space>k is arguably the most ergonomic double-keystroke on
the keyboard.

See the section: `Handling user input` for a more detailed understanding
of how keymappings are achieved.

#TODO
example:

```
Buffer.open() # becomes the active buffer by default
Buffer.active_buffer() # fetches a reference to the active buffer
|> Buffer.modify(insert: Memex.random_quote(), at: cursor(1))
```

### The Flamelex MenuBar #TODO

The MenuBar is currently not functional, but the idea in the future is to
link buttons in the MenuBar directly to modules/functions inside flamelex,
so clicking one will just call that function, probably in it's own MenuBar
supervision tree.

## Basic text editing

Before we start down this journey, let's take a moment to stop and reflect
one last time on how under the hood, all things that happen in flamelex
are just function calls - we are just interacting with the REPL (and
sometimes storing some stuff on some disk/network), and the only way we
do that is via the IEx console.

So then, why do we have a GUI? Well obviously a GUI organizes the information
in a way which is useful for human brains - and those same brains, when
they want to take an action (like, for example, putting a new letter on
the end of a word), would rather achieve that action by pressing a single
button which they have already mentally mapped to that action occuring,
rather than going back to the command line and typing in a more thorough
specification (e.g. `Buffer.modify(b, {:insert, "x"})`) #TODO

In other text-editors, it seems that the specific sequence of button-presses
required to achieve an action, seems to end up defining the entire editor.
I have implemented a few defaults, based on my preferences & history of
using text-editors, but I want to stress that in flamelex, what functions
any particular keystroke or menu-button may take, is completely opaque -
you can peek right on into the code, because *they're all just mappings
to functions*. Hopefully, this will clear up a lot of previous confusion,
and allow a greater ease of customizability for the end user.

The directions given in this README only apply when the default GUI-keymappings
are being used - if that is changed, these will obviously no longer work.

How inputs get mapped to these functions is covered in this document -
you don't have to understand how that works to use flamelex, but if you
would like to know more, please refer to the section
sub-titled: `Handling user input`

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

## the Flamelex API

As a flamelex user, you shouldn't have to look "under the hood". You can,
at any point in time, do so - but hopefully, unless you're merely interested,
you won't ever have to.

All actions that a user can take are defined in the API modules, which are
stored in the API directory. If a user wants to do something, and no
combination of API functions is capable of making it happen, then there
is no other way of doing it safely - the API modules must be updated. But
they must be done so in a safe way, we never want to reach diretly into
the internals of Flamelex, because we might screw things up!

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

The starting point for firing any `action` to the inner-workings of 
flamelex is to look at the `Flamelex.Fluxus` module. This module provides
the interface to firing these actions - when an action is fired, a message
is propagated through an entire tree of processes, which effectively
hold the state of the entire application between them.

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

### A guideline for adding new functionality


#DEVELOPING a new component
Step 1 - figure out where you want to mount the component. #TODO this should be a layer I guess...
  - it needs to get mounted in the GIU somewhere
  - 



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

## Detailed Flamelex manual



## Backlog / TODOs

* Ability to read documents & maintain my own notes on such documents
* Ability to do source-control inside the editor
* Integrated with Elixir compiler
* add MenuBar which is linked to calling functions
& ability to read & search HexDocs

NEXT is MenuBar

