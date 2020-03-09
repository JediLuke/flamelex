# Franklin

A combination text-editor & memex written in Elixir.

## Goals of the project

Franklin was born out of my frustration trying to create the "perfect"
emacs/vim setup. I am a heavy modifier of these programs, but eventually
hard to use APIs and bugs in the software (I consider emacs' inability to
support multi-threading a bug in 2020) prompted me to "flip the desk"
and start from scratch. I chose Elixir because it is a language I know
and love, and because I think the immutable, functional style of Elixir
code, as well as the fact it runs on the BEAM VM, will make Franklin a
very stable editor.

Some of my main goals are:

* Easy for beginners. Comes with tutorial, full help, and good UX (always give the user feedback!)
* Self-documenting
* Contains a personal memex, modelled on tiddlywiki
* REPL driven for absolute programmability

With some notable features:

* Ability to read documents & maintain my own notes on such documents
* Ability to do source-control inside the editor
* Integrated with Elixir compiler
