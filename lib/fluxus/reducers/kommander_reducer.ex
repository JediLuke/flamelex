# defmodule Flamelex.Fluxus.Reducers.Kommander do
#     @moduledoc false
#     use Flamelex.ProjectAliases
#     require Logger
  

#     #   #REMINDER: Don't be tempted to use an alias like
# #   #          alias Flamelex.Buffer.KommandBuffer, it will only break
# #   #          stuff (because I use KommandBuffer explicitely as an atom)

#     ##NOTE: Steps to add a new piece of functionality:
#     #           1) Create a new API function, in an API module
#     #           2) Create a reducer function, in a Reducer module <-- You are here.
#     #           3) Update related components to handle potential new states (just changing between known states should work already, assuming your components know how to render the new state)

#     def process(radix_state, :show) do

#         new_radix_state = radix_state
#         |> put_in([:kommander, :hidden?], false)

#         {:ok, new_radix_state}
#     end

#     def process(radix_state, :hide) do

#         new_radix_state = radix_state
#         |> put_in([:kommander, :hidden?], true)

#         {:ok, new_radix_state}
#     end

# end
  