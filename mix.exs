defmodule SphericalMercator.MixProject do
  use Mix.Project

  def project do
    [
      app: :spherical_mercator,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Spherical Mercator",
      description: description(),
      source_url: "https://github.com/mspanc/elixir-spherical-mercator/",
      package: package()
    ]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp description do
    "spherical_mercator provides projection math for converting between mercator meters, screen pixels (of 256x256 or configurable-size tiles), and latitude/longitude. This is a port of MapBox's SphericalMercator JS library to Elixir."
  end

  defp package do
    [
      name: "spherical_mercator",
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      maintainers: ["Marcin Lewandowski"],
      licenses: ["BSD-3-Clause-Modification"],
      links: %{"GitHub" => "https://github.com/mspanc/elixir-spherical-mercator"}
    ]
  end
end
