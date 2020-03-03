# Architecture

The entire state of the GUI process is held in the Root Scene. I pattern
match on this state, and if necessary, send updates to components which
have self-registered in a callback during init.

This may all change to something more elegant in v2.0