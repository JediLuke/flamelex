defmodule Franklin do

  defmacro __using__(_) do
    quote do
      IO.puts "Welcome to Franklin CLI."
      import Franklin.CLI     # make most common CLI commands tab-completable on CLI
      alias Franklin.CLI      # ^^ this has a lot of noise though, so this can be convenient

      alias Franklin.Buffer.Commander, as: CommandBuffer # because CommandBuffer is fairly separate from any other buffer, we like to think of it as separate, so give it it's own name
    end
  end
end
