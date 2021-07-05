defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  def genotype do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(6)
    %Chromosome{genes: genes, size: 6}
  end

  def fitness_function(chromosome) do
    target = "letras"
    guess = chromosome.genes
    String.jaro_distance(target, List.to_string(guess))
  end

  def terminate?(population, generation), do: hd(population).fitness == 1
end

soln = Genetic.run(Speller, population_size: 1000, selection_type: :elite, selection_rate: 0.9)

IO.write("\n")
IO.inspect(soln, limit: :infinity)
