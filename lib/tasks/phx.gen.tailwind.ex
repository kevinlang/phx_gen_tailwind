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
  """

  use Mix.Task

  #alias Mix.Phoenix.Context
  #alias Mix.Tasks.Phx.Gen
  alias Mix.Phx.Gen.Tailwind.Injector

  #@switches [alpinejs: :boolean]

  @impl true
  def run(_args) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix phx.gen.live must be invoked from within your *_web application root directory"
    end
    # from here on, we can assume we are at the web root directory

    #{opts, _parsed} = OptionParser.parse!(args, strict: @switches)

    context = %{
      web_app_name: Mix.Phoenix.otp_app(),
      in_umbrella?: Mix.Phoenix.in_umbrella?(File.cwd!())
    }

    # 1. copy files
    paths = generator_paths()
    files = [
      {:text, "package.json", "assets/package.json"},
      {:text, "tailwind.config.js", "assets/tailwind.config.js"}
    ]
    Mix.Phoenix.copy_from(paths, "priv/templates/phx.gen.tailwind", [], files)

    # 2. add imports to CSS file
    inject_css_imports()

    # 3. add watcher to config/dev.exs
    inject_dev_config(context)

    # 4. update mix aliases
    inject_mix_aliases()

    # remove css import from app.js
    remove_js_css_import()

    # 5. run 'npm install'
    maybe_run_npm_install()
  end

  defp generator_paths do
    [".", :phx_gen_tailwind]
  end

  defp inject_dev_config(%{in_umbrella?: in_umbrella?} = context) do
    file_path =
      if in_umbrella? do
        Path.expand("../../")
      else
        File.cwd!()
      end
      |> Path.join("config/dev.exs")

    {:ok, file} = read_file(file_path)

    case Injector.dev_config_inject(file, context) do
      {:ok, new_file} ->
        print_injecting(file_path)
        File.write!(file_path, new_file)

      :already_injected ->
        :ok

      {:error, :unable_to_inject} ->
        Mix.shell().info("""
        UNABLE to inject dev/config.exs changes.
        """)
    end
  end

  defp inject_mix_aliases() do
    file_path = "mix.exs"
    file = File.read!(file_path)

    case Injector.mix_aliases_inject(file) do
      {:ok, new_file} ->
        print_injecting(file_path)
        File.write!(file_path, new_file)

      :already_injected ->
        :ok

      {:error, :unable_to_inject} ->
        Mix.shell().info("""
        Unable to inject updated 'assets.deploy' alias
        """)
    end
  end

  defp inject_css_imports() do
    file_path = "assets/css/app.css"
    file = File.read!(file_path)

    case Injector.css_import_inject(file) do
      {:ok, new_file} ->
        print_injecting(file_path)
        File.write!(file_path, new_file)

      :already_injected ->
        :ok

      {:error, :unable_to_inject} ->
        Mix.shell().info("""
        Unable to inject Tailwindcss imports into app.css
        """)
    end
  end

  defp remove_js_css_import() do
    file_path = "assets/js/app.js"
    file = File.read!(file_path)

    case Injector.js_css_import_remove(file) do
      {:ok, new_file} ->
        print_injecting(file_path)
        File.write!(file_path, new_file)

      :already_injected ->
        :ok

      {:error, :unable_to_inject} ->
        Mix.shell().info("""
        Unable to remove css import from app.js
        """)
    end
  end

  defp maybe_run_npm_install() do
    if !!System.find_executable("npm") and Mix.shell().yes?("\nNPM install new dependencies?") do
      cmd = "cd assets/ && npm install"
      Mix.shell().info [:green, "* running ", :reset, cmd]
      Mix.shell().cmd(cmd, [quiet: true])
    end
  end

  defp read_file(file_path) do
    case File.read(file_path) do
      {:ok, file} -> {:ok, file}
      {:error, reason} -> {:error, {:file_read_error, reason}}
    end
  end

  defp print_injecting(file_path, suffix \\ []) do
    Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path), suffix])
  end
end
