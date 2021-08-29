defmodule Mix.Tasks.Phx.Gen.Tailwind do
  @shortdoc "Adds Tailwind to an existing Phoenix application"

  @moduledoc """
  Adds Tailwind to an existing Phoenix application.

      mix phx.gen.tailwind

  It will do the following:

  * Create an `assets/package.json` file.
  * Install `tailwindcss`
  * Create a `tailwind.config.js` file with sane defaults
  * Add tailwind imports to your CSS file
  * Add a Tailwind watcher to your Phoenix endpoint
  * Update the `assets.deploy` mix task to include Tailwind processing

  ## Installing Alpinejs

  This generator can additionally install AlpineJS alongside Tailwind.
  To do that, pass the `--alpinejs` flag.
  """

  use Mix.Task

  alias Mix.Phoenix.Context
  alias Mix.Tasks.Phx.Gen
  alias Mix.Phx.Gen.Tailwind.Injector

  @switches [alpinejs: :boolean]

  @impl true
  def run(args, test_opts \\ []) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix phx.gen.live must be invoked from within your *_web application root directory"
    end
    # from here on, we can assume we are at the web root directory

    {opts, _parsed} = OptionParser.parse!(args, strict: @switches)

    paths = generator_paths()
    files = [
      {:text, "package.json", "assets/package.json"},
      {:text, "tailwind.config.js", "assets/tailwind.config.js"}
    ]
    Mix.Phoenix.copy_from(paths, "priv/templates/phx.gen.tailwind", opts, files)
  end

  defp generator_paths do
    [".", :phx_gen_tailwind]
  end
end
