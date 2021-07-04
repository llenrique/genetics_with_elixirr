defmodule OneMax do
  @behaviour Problem

  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..1000, do: Enum.random(0..1)

    %Chromosome{genes: genes, size: 1000}
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  # Requires a modification in the Problem behaviour to set the temperature
  @impl true
  def terminate?([best | _], generation, temperature), do: temperature < 2
end


soln = Genetic.run(OneMax, population_size: 1000)

IO.write("\n")
IO.inspect(soln, limit: :infinity)
