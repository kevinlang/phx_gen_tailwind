defmodule PhxGenTailwind.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/kevinlang/phx_gen_tailwind"

  def project do
    [
      app: :phx_gen_tailwind,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      #{:phx_new, "1.6.0-rc.0", only: [:dev, :test]},
      # Docs dependencies
      {:ex_doc, "~> 0.20", only: :docs}
    ]
  end
end
