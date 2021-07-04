defmodule OneMax do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..42, do: Enum.random(0..1)

    %Chromosome{genes: genes, size: 42}
  end

  @impl true
  def fitness_function(chromosome) do
    IO.inspect Enum.sum(chromosome.genes)

    val =
      IO.gets("Rate from 1 to 10: ")
      |> String.replace("\n", "")

    String.to_integer(val)

  end

  # Requires a modification in the Problem behaviour to set the temperature
  @impl true
  def terminate?([best | _], generation), do: best.fitness == 1000
end


soln = Genetic.run(OneMax, population_size: 42)

IO.write("\n")
IO.inspect(soln, limit: :infinity)
