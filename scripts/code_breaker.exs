defmodule CodeBreaker do
  @behaviour Problem
  alias Types.Chromosome
  use Bitwise

  def genotype do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end

  def fitness_function(chromosome) do
    target = 'ILoveGeneticAlgorithms'
    encrypted = 'LIjs`B`k`qlfDibjwlqmhv'
    cipher = fn word, key -> Enum.map(word, &rem( bxor(&1, key), 32768)) end
    key =
      chromosome.genes
      |> Enum.map(& Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(List.to_string(target), guess)
  end

  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 1
  end
end

soln = Genetic.run(CodeBreaker, crossover_type: :single_point)

{key, ""} =
  soln.genes
  |> Enum.map(& Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)


IO.write("\n The key is #{key}")
IO.inspect(soln, label: "\nKEY: ")
