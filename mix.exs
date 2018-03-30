defmodule XmlParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :xmlparser,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :erlsom, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:erlsom, "~> 1.4"},
      {:sweet_xml, "~> 0.6.5"},
      {:httpoison, "~> 1.0"},
      {:exomler, git: "https://github.com/vkletsko/exomler.git"},
      {:exml, "~> 0.1.1"},
      {:elixir_xml_to_map, "~> 0.1.1"}
    ]
  end
end
