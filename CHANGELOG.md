# CHANGELOG


#TODO so we need to figure out - do buffers have their own process, independent
#of the GUI, or not??


## v0.2.0

First public release of Franklin.

Because this was the first ever code cut, a feature-wise changelog was
not kept. These are the high level features that were apart of `v0.2.0`

* CLI commands
* Agents - the reminder agent
* Ability to save & store memex in a text file
* Rendering graphics
* Ability to use the command buffer in the graphics
* DevTools - ability to use reload, restart etc.
* Notes - ability to create & save notes
* GUI Dev - include fonts etc
* List buffer - able to render lists (see `Actions.new_buffer(:test)`)

### v0.2.0 notes

I went back & forth a lot over various design - before I totally understood
gproc, I wasn't able to structure the GUI components in a heirarchical manner
which made sense. The heirarchical tuples were the solution to this.

I also suffered from a lot of scope creep - I went from doing basic editing,
to developing a new CLI GUI, to developing a TiddlyWIki, to developing software
agents that are always running to help you. This version tries to show a
MVP for all these features, but is just enough to "get it out the door" and
show the community what I've done so far.

## CHANGELOG Notes

Franklin is versioned using [SemVer](https://semver.org/)