defmodule Flamelex.GUI.Behaviours.LinearLayout do
    @moduledoc """
    Use this to turn your GUI.Component into a LinearLayout - a component
    which renders it's contents along an axis (could be both?) in such
    a way that the entries are lined up nicely (renders flexibly, depending on
    the width/height of the contents).

    Examples include:

    Menubars, e.g.
    "File"   "View"

    (this is perhaps the exception, where fixed-width offsets actually
    do make more sense).

    Tags, e.g.
    | ["some_tag"] | ["short"] | ["and_this_is_a_vary_long"] | ["tag"]

    And text blocks, e.g in StoryRiver for the Memex where we want to
    keep increasing the size of each TidBit, so the full thing gets shown,
    depending on the length of that particular tidbit's contents.
    """

end