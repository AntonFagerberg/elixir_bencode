defmodule ElixirBencode.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_bencode,
     version: "1.0.0",
     elixir: "~> 1.0",
     description: "Bencode encoder / decoder in Elixir.",
     source_url: "https://github.com/AntonFagerberg/elixir_bencode",
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end
  
  defp package do
    [contributors: ["Anton Fagerberg"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/AntonFagerberg/elixir_bencode"}]
  end
end
