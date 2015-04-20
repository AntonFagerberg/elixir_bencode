defmodule ElixirBencode.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_bencode,
     version: "1.0.0",
     elixir: "~> 1.0",
     description: "Bencode encoder / decoder in Elixir.",
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end
  
  defp package do
    [contributors: ["Anton Fagerberg"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/AntonFagerberg/elixir_bencode"}]
  end
end
