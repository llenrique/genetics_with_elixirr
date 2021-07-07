defmodule OneMax do
  @behaviour Problem

  alias Types.Chromosome
  alias Toolbox.Selection

  @impl true
  def genotype do
    genes = for _ <- 1..1000, do: Enum.random(0..1)

    %Chromosome{genes: genes, size: 1000}
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  # Requires a modification in the Problem behaviour to set the temperature
  @impl true
  def terminate?([best | _], generation), do: best.fitness == 1000
end


soln = Genetic.run(OneMax, population_size: 100, selection_type: :elite, alpha: 0.4, crossover_type: :whole_arithmetic_recombination)

IO.write("\n")
IO.inspect(soln, limit: :infinity)
