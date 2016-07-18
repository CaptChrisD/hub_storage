defmodule HubStorage.Mixfile do
  use Mix.Project

  def project do
    [app: :hub_storage,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      { :nerves_hub, github: "nerves-project/nerves_hub" },
      { :persistent_storage, github: "cellulose/persistent_storage" }
    ]
  end
end
