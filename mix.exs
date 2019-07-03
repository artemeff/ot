defmodule OT.MixProject do
  use Mix.Project

  def project do
    [
      app: :ot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5.1", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.0", only: [:dev, :test]},
      {:benchee, "~> 1.0.1", only: [:dev, :test]},
    ]
  end
end
