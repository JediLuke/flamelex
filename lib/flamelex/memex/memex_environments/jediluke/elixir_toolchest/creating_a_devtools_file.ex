defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.CreatingADevToolsFile do

  def description do
    ~s/
    #{step_1()}
    #{step_2()}
    #{step_3()}
    #{step_4()}
    /
  end

  def step_1 do
    ~s|
    In the `mix.exs` file for the project, add an `elixir_paths` entry:

    elixirc_paths: elixirc_paths(Mix.env()),

    e.g.
    ```
    def project do
      [
        app: :sillyz_sample_app,
        version: "1.1.1",
        build_path: "_build",
        config_path: "config/config.exs",
        deps_path: "deps",
        lockfile: "mix.lock",
        elixir: "~> 1.10",
        elixirc_paths: elixirc_paths(Mix.env()),
        start_permanent: Mix.env() == :prod,
        deps: deps()
      ]
    end
    ```

    then you want to add this file in that same `mix.exs`

    ```
    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "test/support"]
    defp elixirc_paths(:dev), do: ["lib", "dev_tools"]
    defp elixirc_paths(_), do: ["lib"]
    ```

    now, Elixir knows to include the `dev_tools` directory, but only when
    compiling in the dev MIX_ENV
    |
  end

  def step_2 do
    ~s(
    Create the DevTools module & use it in command line!

    ```
    defmodule SillyzSampleApp.DevTools do


      def test_dev_tools do
        "DevTools is working!"
      end
    end
    ```

    Then, open CLI

    iex> DevTools.test_dev_tools
    "DevTools is working!"

    )
  end

  def step_3 do
    ~s|
      add a cool macro to devtools to make importing it on CLI even better!!


    ```
    defmodule SillyzSampleApp.DevTools do

      defmacro __using__(_) do
        quote do
          alias Some.Module.{Names, Go, Here}

          import RecordingServices.DevTools
        end
      end

      def test_dev_tools do
        "DevTools is working!"
      end
    end
    ```

    Then, not only can we run whatever useful setup code we want in the
    quotes block, but we have automatically imported all the functions
    in DevTools!

    iex> use SillyzSampleApp.DevTools
    iex> test_dev_tools
    "DevTools is working!"
    |
  end

  def step_4 do
    ~s|Auto-import your dev tools!

    Create a `.iex.exs` file in the root directory. It should contain just
    this line:

    ```
    use_if_available(SillyzSampleApp.DevTools)
    ```

    Now you will automatically run the DevTools macro every time you start
    mix!
    |
  end

  def references do
    [
    ]
  end
end
