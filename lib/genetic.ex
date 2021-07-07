#---
# Excerpted from "Genetic Algorithms in Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/smgaelixir for more book information.
#---
defmodule Genetic do
  alias Types.Chromosome
  alias Toolbox.{Selection, Crossover}

  @spec initialize(fun(), keyword) :: list
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  @spec evaluate([Chromosome.t()], fun(), keyword) :: list
  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> _fit_population(fitness_function)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  @spec _fit_population([Chromosome.t()], fun()) :: list
  defp _fit_population(population, fitness_function) do
    Enum.map(population, &_fit_chromosome(&1, fitness_function))
  end

  @spec _fit_chromosome(Chromosome.t(), fun()) :: Chromosome.t(), fun()
  defp _fit_chromosome(chromosome, fitness_function) do
    fitness = fitness_function.(chromosome)
    age = chromosome.age + 1
    %Chromosome{chromosome | fitness: fitness, age: age}
  end

  @spec select([Chromosome.t()], keyword) :: {[Chromosome.t()], [Chromosome.t()]}
  def select(population, opts \\ []) do
    select_fn =
      Keyword.get(opts, :selection_type, :elite)

    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate) # 100 * 0.8
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents = apply(Selection, select_fn, [population, n])

    left_over =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(left_over)}
  end

  @spec crossover([Chromosome.t()], keyword) :: [Chromosome.t()]
  def crossover(population, opts \\ []) do
    crossover_fn =
      Keyword.get(opts, :crossover_type, :single_point)

    Enum.reduce(population, [], fn {p1, p2} = _parents, acc ->
      {c1, c2} = apply(Crossover, crossover_fn, [p1, p2, opts])
      [c1, c2 | acc]
    end)
  end

  def repair_helper(genes, k) do
    if MapSet.size(genes) >= k do
      MapSet.to_list(genes)
    else
      num = :rand.uniform(8)
      repair_helper(MapSet.put(genes, num), k)
    end
  end

  @spec mutation([Chromosome.t()], keyword) :: list
  def mutation(population, opts \\ []) do
    Enum.map(population, &_shuffle_chromosome_genes(&1))
  end

  @spec _shuffle_chromosome_genes(Chromosome.t()) :: Chromosome.t()
  defp _shuffle_chromosome_genes(chromosome) do
    if :rand.uniform() < 0.05 do
      %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
    else
      chromosome
    end
  end

  @spec run(module(), keyword) :: Chromosome.t()
  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    evolve(population, problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{best.fitness}")
    if problem.terminate?(population, generation) do
      best
    else
      {parents, left_over} = select(population, opts)
      children = crossover(parents, opts)

      children ++ left_over
      # |> mutation(opts)
      |> evolve(problem, generation+1, opts)
    end
  end
end
