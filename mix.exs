defmodule MoreTime.MixProject do
  use Mix.Project

  def project do
    [
      app: :more_time,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/relistan/more_time"},
        maintainers: ["Karl Matthias"]
      ],
      source_url: "https://github.com/relistan/more_time",
      description: """
      MoreTime contains some helpful functions for operating on DateTime-like
      maps. These are useful for rounding and bucketing times in a stable way.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
