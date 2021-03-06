defmodule Genetic do
  alias Types.Chromosome
  alias Toolbox.{Selection, Crossover, Mutation, Reinsertion}
  alias Utilities.{Statistics, Genealogy}

  @spec initialize(fun(), keyword) :: list
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    population = for _ <- 1..population_size, do: genotype.()
    Genealogy.add_chromosomes(population)
    population
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
    crossover_fn = Keyword.get(opts, :crossover_type, :single_point)
    Enum.reduce(population, [], &_crossover(&1, &2, crossover_fn, opts))
  end

  defp _crossover({p1, p2} = _parents, acc, crossover_fn,opts) do
    {c1, c2} = apply(Crossover, crossover_fn, [p1, p2, opts])
    Genealogy.add_chromosome(p1, p2, c1)
    Genealogy.add_chromosome(p1, p2, c2)
    [c1, c2 | acc]
  end

  @spec repair_helper(MapSet.t(any), any) :: list
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
    mutation_fn = Keyword.get(opts, :mutation_type, :simple_shuffle)
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)
    n = floor(length(population) * mutation_rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(fn c ->
      mutant = apply(Mutation, mutation_fn, [c])
      Genealogy.add_chromosome(c, mutant)
      mutant
    end)
  end

  def reinsertion(parents, offspring, left_over, opts \\ []) do
    reinsertion_fn = Keyword.get(opts, :reinsertion_type, :pure)

    apply(Reinsertion, reinsertion_fn, [parents, offspring, left_over, opts])
  end

  @spec run(module(), keyword) :: Chromosome.t()
  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    evolve(population, problem, 0, opts)
  end

  def statistics(population, generation, opts \\ []) do
    default_statistics = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &Enum.sum(Enum.map(&1, fn c -> c.fitness end)) / length(population)
    ]

    stats = Keyword.get(opts, :statistics, default_statistics)

    stats_map =
      stats
      |> Enum.reduce(%{}, fn {key, function}, acc ->
        Map.put(acc, key, function.(population))
      end)

    Statistics.insert(generation, stats_map)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    statistics(population, generation, opts)
    best = hd(population)

    fit_str = :erlang.float_to_binary(best.fitness, decimals: 4)

    IO.write("\rCurrent Best: #{fit_str}\tGeneration: #{generation}")
    if problem.terminate?(population, generation) do
      best
    else
      {parents, left_over} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, left_over, opts)
      evolve(new_population, problem, generation + 1, opts)
    end
  end
end
