defmodule PhxGenTailwind.MixProject do
  use Mix.Project

  @version "0.1.0-rc.0"
  @url "https://github.com/kevinlang/phx_gen_tailwind"

  def project do
    [
      app: :phx_gen_tailwind,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: "Adds Tailwind to a new Phoenix 1.6+ application",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "1.6.0-rc.0"},

      # Docs dependencies
      {:ex_doc, "~> 0.20", only: :docs}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    [
      maintainers: ["Kevin Lang"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => @url}
    ]
  end
end
