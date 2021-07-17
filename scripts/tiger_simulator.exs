defmodule TigerSimulator do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..8, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_function(chromosome) do
    tropic_scores = [0.0, 3.0, 2.0, -1.0, 0.5, 1.0, -1.0, 0.0]
    tundra_scores = [1.0, 3.0, -2.0, 1.0, 0.5, 2.0, 1.0, 0.0]
    traits = chromosome.genes

    traits
    |> Enum.zip(tundra_scores)
    |> Enum.map(fn {trait, score} -> trait * score end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(_population, generation) do
    generation == 150
  end

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)

    avg_fitness = Enum.sum(fitnesses) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers
    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(fn trait ->
        trait
        |> Tuple.to_list()
        |> Enum.sum()
        |> Kernel./(num_tigers)
      end)

    %Chromosome{genes: avg_genes, age: avg_age, fitness: avg_fitness}
  end
end

tiger = Genetic.run(TigerSimulator,
                      population_size: 25,
                      selecttion_rate: 0.9,
                      mutation_rate: 0.1
                      # statistics:
                      #   %{average_tiger: &TigerSimulator.average_tiger(&1)}
                      )

IO.inspect tiger

stats =
  :ets.tab2list(:statistics)
  |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)


{:ok, _cmd} =
  Gnuplot.plot([
    [:set, :title, "mean fintess vs generation"],
    [:plot, "-", :with, :points]
  ], [stats])


# genealogy = Utilities.Genealogy.get_tree()

# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
# {:ok, dot_file} = File.open("tiger_simulation.dot", [:write])
# :ok = IO.binwrite(dot_file, dot)
# :ok = File.close(dot_file)

# IO.write("\n")
# IO.inspect tiger


# IO.write("\n")


# {_, zero_gen_stats} = Utilities.Statistics.lookup(0)
# {_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
# {_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

# IO.inspect(zero_gen_stats.average_tiger, label: "0th: ")
# IO.inspect(fivehundred_gen_stats.average_tiger, label: "500th: ")
# IO.inspect(onethousand_gen_stats.average_tiger, label: "1000th: ")
