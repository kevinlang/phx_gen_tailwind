defmodule Mix.Phx.Gen.Tailwind.Injector do
  @esbuild_watcher_anchor_line "esbuild: {Esbuild, :install_and_run"

  def dev_config_inject(file, context) do
    inject_unless_contains(
      file,
      dev_config_code(context),
      # Matches the entire line containing `anchor_line` and captures
      # the whitespace before the anchor. In the replace string
      #
      # * the entire matching line, sans newline, is inserted with \\1,
      # * a comma is added, and appropriate newline added with \\2
      # * the actual code is injected with &2,
      # * and the appropriate newline is injected using \\2
      &Regex.replace(
        ~r/^(\s*#{@esbuild_watcher_anchor_line}.*)(\r\n|\n|$)/Um,
        &1,
        "\\1,\\2#{&2}\\2",
        global: false
      )
    )
  end

  defp dev_config_code(context) do
    """
        npx: [
          "tailwindcss",
          "--input=css/app.css",
          "--output=../priv/static/assets/app.css",
          "--watch",
          cd: Path.expand("#{dev_config_cd_path(context)}", __DIR__)
        ]
    """
  end

  defp dev_config_cd_path(%{in_umbrella?: false}), do: "../assets"
  defp dev_config_cd_path(%{in_umbrella?: true, web_app_name: path}), do: "../apps/#{path}/assets"

  def mix_aliases_inject(file) do
    with {:ok, file} <- assets_deploy_inject(file),
         {:ok, file} <- setup_alias_inject(file) do
      {:ok, file}
    end
  end

  def assets_deploy_inject(file) do
    inject_unless_contains(
      file,
      "\"cmd --cd assets npm run deploy\", ",
      &Regex.replace(~r/^(.*"assets\.deploy"\: \[)(.*$)/Um, &1, "\\1#{&2}\\2", global: false)
    )
  end

  def setup_alias_inject(file) do
    inject_unless_contains(
      file,
      ", \"cmd --cd assets npm install\"",

      # * the entire matching line, sans newline and last bracket, inserted with \\1
      # * a comma is added, and appropriate newline added with \\2
      # * the actual code is injected with &2
      # * the appropriate closing bracket is injected using \\2
      # * and the appropriate newline is injected using \\3
      &Regex.replace(~r/^(\s*setup\:.*)(\],|\])(\r\n|\n|$)/Um, &1, "\\1#{&2}\\2\\3", global: false)
    )
  end

  def css_import_inject(file) do
    inject_unless_contains(
      file,
      css_import_code(),
      &handle_css_inject/2
    )
  end

  defp css_import_code() do
    """
    @tailwind base;
    @tailwind components;
    @tailwind utilities;
    """
  end

  defp handle_css_inject(code, code_to_inject) do
    if String.contains?(code, ~s(@import "./phoenix.css";)) do
      String.replace(code, ~s(@import "./phoenix.css";), code_to_inject)
    else
      code_to_inject <> code
    end
  end

  def js_css_import_remove(file) do
    {:ok, String.replace(file, "import \"../css/app.css\"", &"// #{&1}", global: false)}
  end

  @doc """
  Injects code unless the existing code already contains `code_to_inject`
  """
  @spec inject_unless_contains(String.t(), String.t(), (String.t(), String.t() -> String.t())) ::
          {:ok, String.t()} | :already_injected | {:error, :unable_to_inject}
  def inject_unless_contains(code, code_to_inject, inject_fn)
      when is_binary(code) and is_binary(code_to_inject) and is_function(inject_fn, 2) do
    with :ok <- ensure_not_already_injected(code, code_to_inject) do
      new_code = inject_fn.(code, code_to_inject)

      if code != new_code do
        {:ok, new_code}
      else
        {:error, :unable_to_inject}
      end
    end
  end

  @spec ensure_not_already_injected(String.t(), String.t()) :: :ok | :already_injected
  defp ensure_not_already_injected(file, inject) do
    if String.contains?(file, inject) do
      :already_injected
    else
      :ok
    end
  end
end
