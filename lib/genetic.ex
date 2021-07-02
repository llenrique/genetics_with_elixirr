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

  @spec select([Chromosome.t()], keyword) :: [Chromosome.t()]
  def select(population, opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @spec crossover([Chromosome.t()], keyword) :: [Chromosome.t()]
  def crossover(population, opts \\ []) do
    Enum.reduce(population, [], &_create_children_chromosomes/2)
  end

  @spec _create_children_chromosomes({Chromosome.t(), Chromosome.t()}, list) :: [[Chromosome.t()]]
  defp _create_children_chromosomes({p1, p2} = _parents, acc) do
    cx_point =
      p1
      |> Map.get(:genes, [])
      |> length()
      |> :rand.uniform()

    {{h1, t1},{h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
    {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p1 | genes: h2 ++ t1}}
    [c1, c2 | acc]
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
    population = initialize(&problem.genotype/0)

    evolve(population, problem, opts)
  end

  @spec evolve([Chromosome.t()], module(), keyword) :: Chromosome.t()
  def evolve(population, problem, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{best.fitness}")
    if problem.terminate?(population) do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, opts)
    end
  end
end
