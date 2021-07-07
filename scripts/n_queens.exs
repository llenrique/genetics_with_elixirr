defmodule NQueens do
  @behaviour Problem
  alias Types.Chromosome

  def genotype do
    genes = Enum.shuffle(0..7)
    %Chromosome{genes: genes, size: 8}
  end

  def fitness_function(chromosome) do
    diag_clahes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)
          dy =
            abs(
              chromosome.genes
              |> Enum.at(i)
              |> Kernel.-(Enum.at(chromosome.genes, j))
            )
          if (dx == dy) do
            1
          else
            0
          end
        else
          0
        end
      end
    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clahes)
  end

  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 8
  end
end


soln = Genetic.run(NQueens, selection_type: :elite, crossover_type: :single_point)
IO.write("\n")
IO.inspect(soln)
